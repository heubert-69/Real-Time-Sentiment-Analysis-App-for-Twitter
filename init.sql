CREATE TABLE IF NOT EXISTS twitter_sentiment (
  id SERIAL PRIMARY KEY,
  tweet TEXT,
  sentiment_score REAL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
