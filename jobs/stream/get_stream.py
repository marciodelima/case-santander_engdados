#!/usr/bin/env python
# coding: utf-8

# # JOB - CAMADA RAW - STREAM
# 
# ## Contrato de Riscos - Quantidade-DIA - Streaming

#Import
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql import functions as F
from pyspark.sql.types import *
from datetime import datetime

import warnings
warnings.filterwarnings("ignore")
#Conf para o parquet - HIVE
from pyspark.conf import SparkConf
conf = SparkConf()
conf.set("spark.sql.parquet.writeLegacyFormat", True)

# Cria a sessão Spark
spark = SparkSession.builder.appName('pipeline-stream').master("local").getOrCreate()

def processarDados(df, epoch_id):
    dataAtual = datetime.today().strftime('%Y%m%d')
    df = df.selectExpr("CAST(value AS STRING)")
    df = df.withColumn("value", from_json(F.col("value"),schema))
    df = df.select("value.*")
    for col in df.columns: 
        df = df.withColumnRenamed(col, col.upper())
    
    df = df.withColumn("DATACADASTRO", to_date(F.col('DATACADASTRO'),"dd/MM/yyyy"))
    df.write.mode("append").json("hdfs://34.151.243.241:9000/datalake/raw/contratosStream/" + dataAtual + "/")
    df.write.mode("append").parquet("hdfs://34.151.243.241:9000/datalake/bronze/contratosStream/" + dataAtual + "/")
    df.write.mode("append").parquet("hdfs://34.151.243.241:9000/datalake/silver/contratosStream/")


schema = StructType([StructField("idcliente",StringType(),True),
                     StructField("idcontrato",StringType(),True),
                     StructField("datacadastro",StringType(),True),
                     StructField("contrato", StringType(),True)])

df = spark   .readStream   .format("kafka")   .option("kafka.bootstrap.servers", "34.151.219.59:9092")   .option("subscribe", "engdados-stream")   .load()

df.writeStream   .format("console")   .option("kafka.bootstrap.servers", "34.151.219.59:9092")   .option("topic", "engdados-stream")   .foreachBatch(processarDados)   .option("checkpointLocation","{}{}".format("/tmp/contratosStream/", "_checkpoint"))   .start()   .awaitTermination()

