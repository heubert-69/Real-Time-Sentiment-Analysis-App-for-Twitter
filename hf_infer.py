from flask import jsonify, Flask, request
import torch
from transformers import pipeline

app = Flask(__name__) #gets the App name from shiny
sentiment_model = pipeline("sentiment-analysis")


@app.route("/sentiment", methods=["POST"]) #directly sending to the shiny UI app
def get_sentiment():
	data = request.get_json()
	text = data.get("text", [])
	results = sentiment_model(text)
	scores = [(r["score"] if r["label"] == "POSITIVE" else -r["score"]) for r in results]
	return jsonify({"scores": scores})

if "__name__" == "__main__": 
	app.run(host="0.0.0.0", port=5000)
