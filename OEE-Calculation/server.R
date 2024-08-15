library(shiny)
library(plotly)

server <- function(input, output) {
  
  observeEvent(input$calculate, {
    TotalShort <- input$shortBreaks * input$shortBreaksNB
    TotalMeal <- input$MealBreak * input$MealBreakNB
    PlannedPrdt <- (input$vardiyasuresi - (TotalShort + TotalMeal)) * input$vardiyasayisi
    Operatingtm <- PlannedPrdt - (input$DownTime * input$vardiyasayisi)
    GoodPieces <- input$TotalPieces - input$RejectedPieces
    
    Availability <- (Operatingtm / PlannedPrdt) * 100
    IdealRatePerMinute <- input$IdealRate / 60
    Performance <- (input$TotalPieces * input$vardiyasayisi) / (IdealRatePerMinute * Operatingtm) * 100
    Quality <- (GoodPieces / input$TotalPieces) * 100
    OEE <- (Availability * Performance * Quality) / 10000
    
    output$availability <- renderText(paste("Kullanılabilirlik: ", round(Availability, 2), "%"))
    output$performance <- renderText(paste("Performans: ", round(Performance, 2), "%"))
    output$quality <- renderText(paste("Kalite: ", round(Quality, 2), "%"))
    
    output$oeeGauge <- renderPlotly({
      plot_ly(
        type = "indicator",
        mode = "gauge+number+delta",
        value = OEE,
        title = list(text = "OEE"),
        delta = list(reference = 85.5),  # Dünya standardı referansı
        gauge = list(
          axis = list(range = list(0, 100)),
          steps = list(
            list(range = c(0, 40), color = "red"),
            list(range = c(40, 80), color = "yellow"),
            list(range = c(80, 100), color = "green")
          ),
          threshold = list(
            line = list(color = "black", width = 4),
            thickness = 0.75,
            value = OEE
          )
        )
      ) %>% layout(margin = list(l = 20, r = 20, b = 20, t = 40)) 
    })
  })
}
