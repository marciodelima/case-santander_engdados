#!/usr/bin/env python
# coding: utf-8

# # JOB - CAMADA SILVER
# 
# ## Data Quality e Deduplicação dos dados, junção histórica

#Import
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql import functions as F
from pyspark.sql.types import *
from pyspark.sql.types import TimestampType
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
spark = SparkSession.builder.appName('pipeline-silver').master("local").getOrCreate()
# Carrega os dados a partir do HDFS - Bronze

#Atual
dadosCli = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/bronze/clientes/" + dataAtual + "/*")
dadosVei = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/bronze/veiculos/" + dataAtual + "/*")
dadosDes = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/bronze/despachantes/" + dataAtual + "/*")
dadosLoc = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/bronze/locacao/" + dataAtual + "/*")
dadosContratos = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/bronze/contratos/" + dataAtual + "/*")

#Tratamento dos dados - Colunas, deduplicacao, juncao historica
dadosCli = dadosCli.withColumn("DATACADASTRO", to_date(F.from_unixtime((F.col('DATACADASTRO')/1000))))
dadosCli = dadosCli.withColumn("DATANASCIMENTO", to_date(F.from_unixtime((F.col('DATANASCIMENTO')/1000))))
dadosCli = dadosCli.withColumn("STATUS", F.upper(F.col('STATUS')))
dadosCli = dadosCli.filter(F.col("STATUS")=='ATIVO')

dadosVei = dadosVei.withColumn("MODELO", F.upper(F.col('MODELO')))
dadosVei = dadosVei.withColumn("STATUS", F.upper(F.col('STATUS')))
dadosVei = dadosVei.filter(F.col("STATUS")=='DISPONÍVEL')

dadosDes = dadosDes.withColumn("FILIAL", F.upper(F.col('FILIAL')))
dadosDes = dadosDes.withColumn("STATUS", F.upper(F.col('STATUS')))
dadosDes = dadosDes.filter(F.col("STATUS")=='ATIVO')

dadosLoc = dadosLoc.withColumn("DATALOCACAO", to_date(F.from_unixtime((F.col('DATALOCACAO')/1000))))
dadosLoc = dadosLoc.withColumn("DATAENTREGA", to_date(F.from_unixtime((F.col('DATAENTREGA')/1000))))

for col in dadosContratos.columns:
    dadosContratos = dadosContratos.withColumnRenamed(col, col.upper())

dadosContratos = dadosContratos.withColumn("DATACADASTRO", to_date(F.col('DATACADASTRO'),"dd/MM/yyyy"))

dadosCli=dadosCli.coalesce(1)
dadosVei=dadosVei.coalesce(1)
dadosDes=dadosDes.coalesce(1)
dadosLoc=dadosLoc.coalesce(1)
dadosContratos=dadosContratos.coalesce(1)

#Historico
try:
    dadosCliS = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/clientes/*")
    dadosVeiS = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/veiculos/*")
    dadosDesS = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/despachantes/*")
    dadosLocS = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/locacao/*")
    dadosContratosS = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/contratos/*")
except:
    dadosCliS = spark.createDataFrame([],StructType([]))
    dadosVeiS = spark.createDataFrame([],StructType([]))
    dadosDesS = spark.createDataFrame([],StructType([]))
    dadosLocS = spark.createDataFrame([],StructType([]))
    dadosContratosS = spark.createDataFrame([],StructType([]))
    pass

#Join e tratamento de duplicados
dadosCliJoin = dadosCli.distinct()
dadosVeiJoin = dadosVei.distinct()
dadosDesJoin = dadosDes.distinct()
dadosLocJoin = dadosLoc.distinct()
dadosContratosJoin = dadosContratos.distinct()

try: 
    dadosCliJoin = dadosCli.unionAll(dadosCliS).distinct()
    dadosVeiJoin = dadosVei.unionAll(dadosVeiS).distinct()
    dadosDesJoin = dadosDes.unionAll(dadosDesS).distinct()
    dadosLocJoin = dadosLoc.unionAll(dadosLocS).distinct()
    dadosContratosJoin = dadosContratos.unionAll(dadosContratosS).distinct()
except:
    pass

#Gravacao - Camada Silver
dadosCliJoin.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/silver/clientes/")
dadosVeiJoin.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/silver/veiculos/")
dadosDesJoin.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/silver/despachantes/")
dadosLocJoin.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/silver/locacao/")
dadosContratosJoin.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/silver/contratos/")
