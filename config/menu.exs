# примерно так должно выглядеть меню
 %{
   "report_sub_menu" => %TlgmBot.Models.TlgmMenu{
      inline: false,
      buttons: [
       # [
       #   %TlgmBot.Models.TlgmButton{
       #     action: MinBlagoBot.Handlers.Report.action_report,
       #     data: nil,
       #     module: MinBlagoBot.Handlers.Report.name,
       #     text: "ОБНОВИТЬ"
       #   }
       # ],
        [
           %TlgmBot.Models.TlgmButton{
             action: MinBlagoBot.Handlers.Report.action_planned,
             data: nil,
             module: MinBlagoBot.Handlers.Report.name,
             text: "СОДЕРЖАНИЕ"
           },
           %TlgmBot.Models.TlgmButton{
             action: MinBlagoBot.Handlers.Report.action_snow,
             data: nil,
             module: MinBlagoBot.Handlers.Report.name,
             text: "УБОРКА СНЕГА"
           }
        ]
      ]
   }
 }
