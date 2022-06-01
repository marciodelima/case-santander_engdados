#!/usr/bin/env python
# coding: utf-8

# # JOB - CAMADA BRONZE
# 
# ## Equalização em PARQUET, aplicação de anominização de dados - LGPD - MD5

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

dataAtual = datetime.today().strftime('%Y%m%d')
#dataAtual = '20220528'

# Cria a sessão Spark
spark = SparkSession.builder.appName('pipeline-bronze').master("local").getOrCreate()
# Carrega os dados a partir do HDFS - RAW

dadosCli = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/raw/clientes/" + dataAtual + "/*")
dadosVei = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/raw/veiculos/" + dataAtual + "/*")
dadosDes = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/raw/despachantes/" + dataAtual + "/*")
dadosLoc = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/raw/locacao/" + dataAtual + "/*")
#json
dadosContratos = spark.read.option("multiline","true").json("hdfs://34.151.243.241:9000/datalake/raw/contratos/" + dataAtual + "/*")

#Tratamento dos dados - Limpeza, Anominização , Coalesce
dadosCli = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/raw/clientes/" + dataAtual + "/*")
dadosVei = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/raw/veiculos/" + dataAtual + "/*")
dadosDes = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/raw/despachantes/" + dataAtual + "/*")
dadosLoc = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/raw/locacao/" + dataAtual + "/*")
#json
dadosContratos = dadosContratos.drop(F.col("_id"))

dadosCli = dadosCli.withColumn("CPF", F.md5("CPF")).withColumn("CNH", F.md5("CNH")).withColumn("TELEFONE", lit(0)).withColumn("NOME", lit('ANONIMIZADO'))
dadosDes = dadosDes.withColumn("NOME", lit('ANONIMIZADO'))

dadosCli.coalesce(1)
dadosVei.coalesce(1)
dadosDes.coalesce(1)
dadosLoc.coalesce(1)
dadosContratos.coalesce(1)

#Gravacao - Camada Bronze
dadosCli.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/bronze/clientes/" + dataAtual + "/")
dadosVei.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/bronze/veiculos/" + dataAtual + "/")
dadosDes.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/bronze/despachantes/" + dataAtual + "/")
dadosLoc.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/bronze/locacao/" + dataAtual + "/")
dadosContratos.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/bronze/contratos/" + dataAtual + "/")
                                  

