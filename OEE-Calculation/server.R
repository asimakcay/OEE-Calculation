library(shiny)
library(plotly)
library(openxlsx)
library(ggplot2)

turkce_aylar <- c("Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", 
                  "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık")

server <- function(input, output, session) {
  data <- reactiveValues(oee_data = data.frame(Ay = character(), OEE = numeric(), 
                                               PlannedProduction = numeric(), 
                                               OperatingTime = numeric(), 
                                               GoodPieces = numeric(),
                                               stringsAsFactors = FALSE))

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
    
    output$plannedProduction <- renderText(paste("Planlanan Üretim Süresi: ", PlannedPrdt, " Dakika"))
    output$operatingTime <- renderText(paste("Çalışma Süresi: ", Operatingtm, " Dakika"))
    output$goodPieces <- renderText(paste("Vardiya Başına Düşen Sağlam Ürün: ", GoodPieces))
    
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
    
    data$oee_data <- rbind(data$oee_data, data.frame(Ay = input$month, 
                                                     OEE = OEE,
                                                     PlannedProduction = PlannedPrdt,
                                                     OperatingTime = Operatingtm,
                                                     GoodPieces = GoodPieces))
    data$oee_data$Ay <- factor(data$oee_data$Ay, levels = turkce_aylar)
    data$oee_data <- data$oee_data[order(data$oee_data$Ay), ]
    
    output$monthlyOEEPlot <- renderPlotly({
      plot_ly(data = data$oee_data, x = ~Ay, y = ~OEE, type = 'scatter', mode = 'lines+markers', name = 'OEE') %>%
        layout(title = "Aylık OEE Değerleri",
               xaxis = list(title = "Ay"),
               yaxis = list(title = "OEE Değeri (%)"))
    })
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("OEE_Data_", Sys.Date(), ".xlsx", sep = "")
    },
    content = function(file) {

      wb <- createWorkbook()

      addWorksheet(wb, "OEE Data")
      writeData(wb, "OEE Data", data$oee_data)
      
      addWorksheet(wb, "OEE Grafik")

      g <- ggplot(data$oee_data, aes(x = Ay, y = OEE, group = 1)) +
        geom_line() +
        geom_point() +
        labs(title = "Aylık OEE Değerleri", x = "Ay", y = "OEE Değeri (%)")

      plot_file <- tempfile(fileext = ".png")
      ggsave(plot_file, plot = g, width = 8, height = 6)
      
      insertImage(wb, "OEE Grafik", file = plot_file, width = 8, height = 6, startRow = 1, startCol = 1)

      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
}
