/// Serviço de notificações locais do aplicativo.
///
/// Este serviço gerencia notificações locais para lembretes de tarefas.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Serviço responsável por gerenciar notificações locais.
///
/// Permite agendar, cancelar e gerenciar notificações de lembretes
/// para tarefas do usuário.
class NotificationService {
  /// Instância singleton do serviço.
  static final NotificationService _instance = NotificationService._internal();

  /// Construtor factory que retorna a instância singleton.
  factory NotificationService() => _instance;

  /// Construtor privado.
  NotificationService._internal();

  /// Plugin de notificações locais.
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Indica se o serviço foi inicializado.
  bool _isInitialized = false;

  /// ID do canal de notificações Android.
  static const String _channelId = 'task_reminders';

  /// Nome do canal de notificações Android.
  static const String _channelName = 'Lembretes de Tarefas';

  /// Descrição do canal de notificações Android.
  static const String _channelDescription =
      'Notificações de lembretes para suas tarefas';

  /// Inicializa o serviço de notificações.
  ///
  /// Deve ser chamado antes de usar qualquer funcionalidade de notificação.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Inicializa timezone
    tz.initializeTimeZones();

    // Configurações para Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configurações para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configurações para Linux
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Abrir',
    );

    // Combina todas as configurações
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    // Inicializa o plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Cria canal de notificação no Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }

    _isInitialized = true;
  }

  /// Cria o canal de notificação no Android.
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Callback quando uma notificação é tocada.
  void _onNotificationTapped(NotificationResponse response) {
    // Reason: Aqui podemos navegar para a tarefa específica
    // usando o payload que contém o ID da tarefa.
    debugPrint('Notificação tocada: ${response.payload}');
  }

  /// Solicita permissão para notificações.
  ///
  /// Returns:
  ///   true se a permissão foi concedida.
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true; // Linux não precisa de permissão
  }

  /// Agenda uma notificação para uma tarefa.
  ///
  /// Args:
  ///   taskId: ID da tarefa (usado como ID da notificação).
  ///   title: Título da notificação.
  ///   body: Corpo da notificação.
  ///   scheduledDate: Data e hora para exibir a notificação.
  ///
  /// Returns:
  ///   true se a notificação foi agendada com sucesso.
  Future<bool> scheduleTaskReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) await initialize();

    // Não agenda se a data já passou
    if (scheduledDate.isBefore(DateTime.now())) {
      return false;
    }

    try {
      // Gera um ID numérico a partir do UUID da tarefa
      final notificationId = taskId.hashCode.abs() % 2147483647;

      // Detalhes da notificação Android
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      // Detalhes da notificação iOS
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Detalhes da notificação Linux
      const linuxDetails = LinuxNotificationDetails();

      // Combina detalhes de todas as plataformas
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        linux: linuxDetails,
      );

      // Converte para timezone local
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Agenda a notificação
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
      );

      debugPrint('Notificação agendada para: $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('Erro ao agendar notificação: $e');
      return false;
    }
  }

  /// Cancela a notificação de uma tarefa.
  ///
  /// Args:
  ///   taskId: ID da tarefa.
  Future<void> cancelTaskReminder(String taskId) async {
    if (!_isInitialized) return;

    final notificationId = taskId.hashCode.abs() % 2147483647;
    await _notifications.cancel(notificationId);
    debugPrint('Notificação cancelada para tarefa: $taskId');
  }

  /// Cancela todas as notificações.
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) return;
    await _notifications.cancelAll();
    debugPrint('Todas as notificações canceladas');
  }

  /// Exibe uma notificação imediata.
  ///
  /// Útil para testes ou notificações instantâneas.
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 2147483647,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Verifica se há notificações pendentes para uma tarefa.
  Future<bool> hasScheduledReminder(String taskId) async {
    if (!_isInitialized) return false;

    final pending = await _notifications.pendingNotificationRequests();
    final notificationId = taskId.hashCode.abs() % 2147483647;

    return pending.any((n) => n.id == notificationId);
  }

  /// Lista todas as notificações pendentes.
  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    if (!_isInitialized) return [];
    return _notifications.pendingNotificationRequests();
  }
}
