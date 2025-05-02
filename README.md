# Real-Time-Sentiment-Analysis-App-for-Twitter
# Project: Real-Time Twitter Sentiment Analysis Dashboard in R (Optimized with Hugging Face + ONNX) # Containerized with Docker and backed by PostgreSQL


# Real-Time Twitter Sentiment Analysis (R + Hugging Face + ONNX + Docker)

This project monitors tweets in real time, analyzes sentiment using Hugging Face transformers, and stores the results in PostgreSQL. The frontend is a Shiny dashboard in R.

## Features
- Real-time Twitter tracking with `rtweet`
- Sentiment analysis using Hugging Face Transformers (`distilbert-base-uncased-finetuned-sst-2-english`)
- Fast Python microservice with Flask
- Interactive dashboard using Plotly in Shiny
- Fully containerized with Docker and PostgreSQL

## Requirements
- Docker & Docker Compose
- Twitter API access

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourname/twitter-sentiment-hf.git
cd twitter-sentiment-hf
```

### 2. Twitter Token Setup in R
```r
library(rtweet)
create_token(
  app = "your_app_name",
  consumer_key = "your_consumer_key",
  consumer_secret = "your_consumer_secret",
  access_token = "your_access_token",
  access_secret = "your_access_secret"
)
```

### 3. Run the App
```bash
docker-compose up --build
```
Access the dashboard at [http://localhost:3838](http://localhost:3838)

### 4. Stop the App
```bash
docker-compose down
```

## PostgreSQL Table Schema
```sql
CREATE TABLE twitter_sentiment (
  id SERIAL PRIMARY KEY,
  tweet TEXT,
  sentiment_score REAL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Notes
- Python microservice uses Hugging Face and Torch
- R app communicates with the microservice via HTTP POST
- Consider using ONNX runtime for faster inference if scaling
