library("shiny") #for App development in R
library("rtweet") #using the Twitter API
library("dplyr")
library("ggplot2")
library("plotly")
library("DBI")
library("RPostgres")
library("httr") #for web api
library("jsonlite") #for web requests
auth_setup_default()


#for importing twitter API
create_token(
  app = "YOUR-APP-NAME",
  consumer_key = "Key",
  consumer_secret = "Key",
  access_token =  "Key",
  access_secret = "Key"
)


auth <- rtweet_app(
	key = "Key",
        secret = "Key",
	access_token = "Key",
	access_secret = "Key"
)

auth_as(auth)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "sentiment_db"),
  host = Sys.getenv("DB_HOST", "localhost"),
  user = Sys.getenv("DB_USER", "postgres"),
  password = Sys.getenv("DB_PASSWORD", "postgres"),
  port = 5432
)

ui <- fluidPage(
	titlePanel("Real Time Twitter Sentiment Analysis w/ Hugging Face :D"),
	sidebarLayout(
		sidebarPanel(textinput("keyword", "Keyword To Track", value=AI), textinput("start", "Start Tracking"),textinput("stop", "Stop"))
	),
	 mainPanel(plotlyOutput("Sentiment Output Plot"), tableOutput("Tweets Table")) 
)

#very long ass line for the realtime server scraper of twitter
server <- function(input, output, session) {
  tracking <- reactiveVal(FALSE)
  tweet_data <- reactiveVal(data.frame())

  observeEvent(input$start, tracking(TRUE))
  observeEvent(input$stop, tracking(FALSE))

  autoUpdater <- reactiveTimer(10000)

  observe({
    autoUpdater()
    req(tracking())

    tweets <- tryCatch({
      search_tweets(input$keyword, n = 30, lang = "en", include_rts = FALSE)
    }, error = function(e) return(NULL))

    if (!is.null(tweets) && nrow(tweets) > 0) {
      texts <- gsub("[^[:alnum:] ]", "", tweets$text)

      # POST to Python microservice
      response <- POST("http://inference:5000/sentiment", 
                       body = list(text = texts),
                       encode = "json")

      if (status_code(response) == 200) {
        scores <- content(response)$scores
        
        new_data <- data.frame(
          tweet = texts,
          sentiment_score = unlist(scores),
          created_at = Sys.time()
        )

        dbWriteTable(con, "twitter_sentiment", new_data, append = TRUE, row.names = FALSE)
        combined <- bind_rows(tweet_data(), new_data) %>% tail(200)
        tweet_data(combined)
      }
    }
  })
}
#real time data extraction to compute sentiment scores
 output$sentimentPlot <- renderPlotly({
    req(nrow(tweet_data()) > 0)
    plot_data <- tweet_data() %>%
      mutate(time_bucket = as.POSIXct(cut(created_at, "30 sec"))) %>%
      group_by(time_bucket) %>%
      summarise(avg_sentiment = mean(sentiment_score))

    p <- ggplot(plot_data, aes(x = time_bucket, y = avg_sentiment)) +
      geom_line(color = "blue") +
      labs(title = "Average Sentiment Over Time", x = "Time", y = "Sentiment")
    ggplotly(p)
  })

  output$tweetsTable <- renderTable({
    req(nrow(tweet_data()) > 0)
    head(tweet_data()[, c("tweet", "sentiment_score")], 10)
  })
rtweet::auth_as("twitter_auth")

shinyApp(ui=ui, server=server)
