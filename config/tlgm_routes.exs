#набор маршрутов для команд бота
# старт есть всегда в боте.
%{
  TlgmBot.Handlers.Start.get_cmd()      => MinBlagoBot.Handlers.Report,
  MinBlagoBot.Handlers.Report.get_cmd() => MinBlagoBot.Handlers.Report
}


