#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
#negBin<- stan_model("NegBin.stan")

p_accept<- function(i,dat,conf,target){
  Ts <- sum(dat$x)
  t_x <- rnbinom(1000,Ts,dat$M / (dat$M + i))
  mean(conf * (sqrt((dat$N - dat$M + i)/(dat$N*(t_x + Ts)))) < target)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  ## maybe this is event reactive
  rv <- reactiveValues(x=c(),dat=c(),z=c(),temp=c(),p_a=c(),Confid=c())
  observeEvent(input$up,{
    rv$temp <- input$current
    updateNumericInput(session,"current",value=rv$temp+1)  
  })
  observeEvent(input$Calc,{
    rv$x <- c(rv$x,input$current)
    rv$dat <- list(N=input$total_fov,M=length(rv$x),x=rv$x)
    ## points come from a poisson distribution
    rv$z <- rpois(1000,rgamma(1000,sum(rv$x),length(rv$x))*(rv$dat$N - rv$dat$M))
    output$nsam <- renderText(length(rv$x))
    #output$Confidence <- renderText(round(100*( qnorm(0.5 + input$conf/200) - qnorm(0.5 - input$conf/200) ) * sqrt((rv$dat$N - rv$dat$M) /(sum(rv$x) * input$total_fov)),2))
    output$xs <- renderText(rv$x)
    output$Exp <- renderText(sum(rv$x) * (rv$dat$N - rv$dat$M)/rv$dat$M + sum(rv$x))

    rv$temp <- optim(0.5 - input$conf/200,function(x){
      diff(qnbinom(c(x,x+0.95),sum(rv$x),rv$dat$M/rv$dat$N))
    },upper=1-input$conf/100,lower=0,method="Brent")$value
    
    ## debug here
    #rv$temp <- optim(0.5 - input$conf/200,function(x){diff(qnbinom(c(x,x+input$conf/100),sum(rv$x),rv$dat$M/rv$dat$N))},method="L-BFGS-B",upper=1-input$conf/100,lower=0)$value
    rv$Confid<- rv$temp/(sum(rv$x) * (rv$dat$N - rv$dat$M)/rv$dat$M + sum(rv$x))*100
    output$Confidence <- renderText(rv$Confid)
    #print(rv$temp)
    
    
    rv$p_a <- sapply(1:20, p_accept, dat=rv$dat,conf = qnorm(0.5 + input$conf/200) - qnorm(0.5 - input$conf/200), target = input$error/100)
    output$ExpFow <- renderText( ifelse(length(rv$x) > 2,
      ifelse(rv$Confid <= input$error,0,
      min(c(which(rv$p_a > 0.5),99))),"Collect 3 samples before calculating this")
      )
    updateNumericInput(session,"current",value=0)
    
    # browser()
    # left <- rv$dat$N - rv$dat$M
    # Ts <- sum(rv$x)
    # done <- rv$temp/(sum(rv$x) * (rv$dat$N - rv$dat$M)/rv$dat$M + sum(rv$x))*100 < input$error
    # #browser()
    # i <- 0
    # while(done == F)
    # {
    #   i <- i + 1
    #   t_x <- rnbinom(1000,Ts,rv$dat$M / (rv$dat$M + i))
    #   if ((qnorm(0.5 + input$conf/200) - qnorm(0.5 - input$conf/200)) * mean(sqrt((rv$dat$N - rv$dat$M + i)/(dat$N*(t_x + Ts)))) < input$error/100)
    #   {
    #     done <- T
    #   }
    # }
    # #browser()
    # output$ExpFow <- renderText(i)

})
  
  observeEvent(input$Fin,{
    #save everything
    ## write comment/mean/var/samples 
    mea <- sum(rv$x) * (rv$dat$N - rv$dat$M)/rv$dat$M + sum(rv$x)
    cat(input$ID,input$Comment,mea,mea * rv$dat$N / rv$dat$M,rv$x,"\n",sep=",",file=input$file_save,append=T)
    #reset everything
    updateNumericInput(session,"current",value=0)
    rv$temp <- input$ID + 1
    updateNumericInput(session,"ID",value = rv$temp)
    rv$x=c();rv$dat=c();rv$z=c();rv$temp=c();rv$p_a=c();rv$Confid=c()
  })

  output$distPlot <- renderPlot({
    if (length(rv$x) > 0){
    # draw the histogram with the specified number of bins
      hist(rv$z+sum(rv$x),probability = F,main="",xlab="no in Complete base plate",ylab="Density",axes=F)
      axis(1)
      axis(2,labels = F)
    }
    
  })
  output$expPlot <- renderPlot({
    if (length(rv$x) > 0){
      plot(1:20,rv$p_a,xlab="More fields of view",ylab="Estimated probaility of reaching target",ylim=c(0,1))
    }
  })
})
