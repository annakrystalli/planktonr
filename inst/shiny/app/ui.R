#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Counting plankton"),
  
  # Sidebar with a slider input for number of bins 
  fluidRow(
  column(12,
    fluidRow(
    column(4,numericInput("total_fov","Total fields of view",value=500)
           ,sliderInput("conf",
                        "Confidence",
                        min = 1,
                        max = 100,
                        value = 95,step=1)
    ,numericInput("error","Target range (%)",value=50)
    ),
    column(4,numericInput("current","Current field of view",value=0)
           ,actionButton("up","+1")
           ,actionButton("Calc","Calculate")
    ),
    column(4,textInput("file_save","File",value=".csv")
           ,numericInput("ID","Field of view ID",value=1)
           ,textInput("Comment","Comments",value="sample 1")
           ,actionButton("Fin","Finished")
  )),
  fluidRow(
    column(4,
           plotOutput("distPlot")
    ),column(4,
             p("Number sampled:", style = "color:#888888;"),
             verbatimTextOutput("nsam"),
             p("Current confidence (%):", style = "color:#888888;"), 
             verbatimTextOutput("Confidence")
             ,p("Sample:", style = "color:#888888;")
             ,verbatimTextOutput("xs")
             ,p("Expected number on total base plate:", style = "color:#888888;")
             ,verbatimTextOutput("Exp")
             ,p("Expected number of extral fields of view:", style = "color:#888888;")
             ,verbatimTextOutput("ExpFow")
             ),
    column(4,
           plotOutput("expPlot")
    ))
  )
  )
    # Show a plot of the generated distribution
    #mainPanel(
     #  plotOutput("distPlot")
  )
)
