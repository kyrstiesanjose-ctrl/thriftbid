import mysql.connector

from optimization import run_optimization
# from overview import run_overview
# from performance import run_performance
# from optimization import run_optimization
# from forecast import run_forecast


connection = mysql.connector.connect(
    host="ccscloud.dlsu.edu.ph",
    port=22003,
    user="CBDBADM01",
    password="y9pSAee2MURj",
    database="thriftbid_db2"
)


cursor = connection.cursor()

# ============================================
# Select which dashboard to run
# ============================================


run_optimization(cursor)

# run_overview(cursor)
# run_performance(cursor)
# run_sales_driver(cursor)
# run_forecast(cursor)

cursor.close()
connection.close()