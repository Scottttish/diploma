import 'package:flutter/material.dart';

/// Central color registry. Every color used in the app lives here.
/// Never hardcode hex values in widget files — always reference this class.
abstract final class AppColors {
  // Primary structural colors
  static const Color operationalBlue = Color(0xFF244A6B);
  static const Color concreteGray = Color(0xFFEEF2F5);
  static const Color safetyOrange = Color(0xFFFF8A00);

  // Scaffolding
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F6F9);
  static const Color onSurface = Color(0xFF111827);
  static const Color onSurfaceMuted = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // Priority status indicators — these map 1:1 to TaskPriority enum values
  static const Color priorityCritical = Color(0xFFDC2626);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityNormal = Color(0xFF3B82F6);
  static const Color priorityCompleted = Color(0xFF16A34A);

  // Chat bubble backgrounds
  static const Color bubbleOutgoing = Color(0xFF244A6B);
  static const Color bubbleIncoming = Color(0xFFEEF2F5);
  static const Color onBubbleOutgoing = Color(0xFFFFFFFF);
  static const Color onBubbleIncoming = Color(0xFF111827);

  // Dispatcher messages get a slightly distinct shade so they read
  // differently from client messages at a glance
  static const Color bubbleDispatcher = Color(0xFFDDE7F0);

  // Timeline track colors
  static const Color timelineActive = Color(0xFF244A6B);
  static const Color timelineCompleted = Color(0xFF16A34A);
  static const Color timelinePending = Color(0xFFD1D5DB);
}
