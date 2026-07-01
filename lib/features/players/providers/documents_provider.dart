library;

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../../core/storage/cloud_storage_providers.dart';
import '../models/document_label.dart';
import '../models/player_document_model.dart';
import 'player_profile_provider.dart';
import 'player_providers.dart';

part 'documents_provider.g.dart';

const List<String> _kAcceptedFileTypes = ['pdf', 'jpg', 'jpeg', 'png'];
const int _kMaxPdfBytes = 10 * 1024 * 1024;
const int _kImageCompressQuality = 85;

class DocumentsState {
  const DocumentsState({
    this.isUploading = false,
    this.isDeleting = false,
    this.errorMessage,
    this.uploadSuccess = false,
  });

  final bool isUploading;
  final bool isDeleting;
  final String? errorMessage;
  final bool uploadSuccess;

  DocumentsState copyWith({
    bool? isUploading,
    bool? isDeleting,
    String? Function()? errorMessage,
    bool? uploadSuccess,
  }) {
    return DocumentsState(
      isUploading: isUploading ?? this.isUploading,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
    );
  }
}

@riverpod
class DocumentsNotifier extends _$DocumentsNotifier {
  @override
  DocumentsState build(String playerId) => const DocumentsState();

  Future<void> uploadDocument({
    required String playerId,
    required DocumentLabel selectedLabel,
    String? customLabel,
    required File file,
    required String fileExtension,
  }) async {
    state = state.copyWith(
      isUploading: true,
      errorMessage: () => null,
      uploadSuccess: false,
    );

    final extension = fileExtension.toLowerCase();
    if (!_kAcceptedFileTypes.contains(extension)) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: () => 'documentFileTypeInvalid',
      );
      return;
    }

    Uint8List bytes;
    if (extension == 'pdf') {
      final fileSize = await file.length();
      if (fileSize > _kMaxPdfBytes) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: () => 'documentFileTooLarge',
        );
        return;
      }
      bytes = await file.readAsBytes();
    } else {
      final rawBytes = await file.readAsBytes();
      bytes = await FlutterImageCompress.compressWithList(
        rawBytes,
        quality: _kImageCompressQuality,
      );
    }

    final documentId = FirebaseFirestore.instance
        .collection('players')
        .doc(playerId)
        .collection('documents')
        .doc()
        .id;

    final fileName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : '$documentId.$extension';
    final storagePath =
        'players/$playerId/documents/$documentId/$fileName';

    final storageService = ref.read(cloudStorageProvider);
    final uploadResult = await storageService.uploadFile(storagePath, bytes);

    final String fileUrl;
    switch (uploadResult) {
      case Success(:final value):
        fileUrl = value;
      case Failure(:final exception):
        state = state.copyWith(
          isUploading: false,
          errorMessage: () => exception.message,
        );
        return;
    }

    final label = selectedLabel == DocumentLabel.other
        ? (customLabel ?? '')
        : selectedLabel.displayName;

    final document = PlayerDocumentModel(
      id: documentId,
      label: label,
      fileUrl: fileUrl,
      fileType: extension,
      uploadedAt: DateTime.now(),
    );

    final repo = ref.read(playerRepositoryProvider);
    final addResult = await repo.addDocument(playerId, document);
    switch (addResult) {
      case Success():
        state = state.copyWith(isUploading: false, uploadSuccess: true);
        ref.invalidate(playerDocumentsProvider(playerId));
      case Failure(:final exception):
        state = state.copyWith(
          isUploading: false,
          errorMessage: () => exception.message,
        );
    }
  }

  Future<void> deleteDocument({
    required String playerId,
    required PlayerDocumentModel document,
  }) async {
    state = state.copyWith(isDeleting: true, errorMessage: () => null);

    final repo = ref.read(playerRepositoryProvider);
    final deleteResult = await repo.deleteDocument(playerId, document.id);

    switch (deleteResult) {
      case Failure(:final exception):
        state = state.copyWith(
          isDeleting: false,
          errorMessage: () => exception.message,
        );
        return;
      case Success():
        break;
    }

    final storageService = ref.read(cloudStorageProvider);
    final storagePath = _storagePathFromUrl(document.fileUrl);
    if (storagePath != null) {
      await storageService.deleteFile(storagePath);
    }

    state = state.copyWith(isDeleting: false);
    ref.invalidate(playerDocumentsProvider(playerId));
  }

  String? _storagePathFromUrl(String fileUrl) {
    final uri = Uri.tryParse(fileUrl);
    if (uri == null) return null;
    final match = RegExp(r'/o/([^?]+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.decodeComponent(match.group(1)!);
  }
}
