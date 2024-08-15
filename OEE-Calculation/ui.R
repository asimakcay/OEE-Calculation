library(shiny)
library(plotly)

# UI tanımlama
ui <- fluidPage(
  
  titlePanel("OEE Hesaplama Aracı"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("vardiyasuresi", "Vardiya Süresi (dk):", value = 0),
      numericInput("vardiyasayisi", "Vardiya Sayısı:", value = 0),
      numericInput("shortBreaks", "Kısa Mola (dk):", value = 0),
      numericInput("shortBreaksNB", "Kısa Mola Adedi:", value = 0),
      numericInput("MealBreak", "Yemek Molası (dk):", value = 0),
      numericInput("MealBreakNB", "Yemek Mola Adedi:", value = 0),
      numericInput("DownTime", "Duraklama Süresi (dk):", value = 0),
      numericInput("IdealRate", "İdeal Üretim Hızı (parça/sa):", value = 0),
      numericInput("TotalPieces", "Toplam Üretilen Parça:", value = 0),
      numericInput("RejectedPieces", "Reddedilen Parça:", value = 0),
      
      actionButton("calculate", "Hesapla")
    ),
    
    mainPanel(
      fluidRow(
        column(4,
               h3("Sonuçlar"),
               textOutput("availability"),
               textOutput("performance"),
               textOutput("quality")
        ),
        column(8,
               plotlyOutput("oeeGauge", height = "400px", width = "100%")  # Grafik için genişlik ve yükseklik ayarı
        )
      )
    )
  )
)
