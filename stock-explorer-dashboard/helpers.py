# helpers.py

import yfinance as yf
import pandas as pd
import cufflinks as cf

# ticker -> stock
def get_stock(ticker):
    return yf.Ticker(ticker.upper())

# stock -> data
def get_data(stock, period = "1y"):
    return stock.history(period = period)

# data -> current price
def get_price(data):
    return f'{data["Close"].iloc[-1]:,.2f}'

# data -> change
def get_change(data):
    current_price = data["Close"].iloc[-1]
    last_price = data["Close"].iloc[-2]
    change = current_price - last_price
    return {
        'amount': f"${abs(change):.2f}",
        'percent': f"{change / last_price * 100:.2f}",
        'color': 'success' if change >= 0 else 'danger',
        'icon': 'arrow-up' if change >= 0 else 'arrow-down'
    }

# data -> OHLC table
def make_OHLC_table(data):
    return {
        'date': data.reset_index()['Date'].iloc[-1].date().strftime('%Y-%m-%d'),
        'open': f"${data['Open'].iloc[-1]:.2f}",
        'high': f"${data['High'].iloc[-1]:.2f}",
        'low': f"${data['Low'].iloc[-1]:.2f}",
        'close': f"${data['Close'].iloc[-1]:.2f}",
        'volume': f"{data['Volume'].iloc[-1]:,.0f}"
    }

# data -> candlestick chart
def make_candlestick_chart(data, ticker):
    cf.go_offline()
    qf=cf.QuantFig(data,legend='top',name=ticker, up_color='#44bb70', down_color='#040548')
    qf.add_sma()
    qf.add_volume(up_color='#44bb70', down_color='#040548')
    return qf.iplot()