#структура вида
#alias => {module, action}
#%{
#  "i" => {"info", "show"}
#}
%{
  # перенаправляем старт на нужный контроллер
  TlgmBot.Handlers.Start.get_cmd => {MinBlagoBot.Handlers.Report.name, MinBlagoBot.Handlers.Report.action_report}
}
