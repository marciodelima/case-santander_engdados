#!/usr/bin/env python
# coding: utf-8

# # JOB - CAMADA GOLD
# 
# ## Sumarização de dados, KPIs de Negocio

# In[1]:


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
spark = SparkSession.builder.appName('pipeline-gold').master("local").getOrCreate()

# Carrega os dados a partir do HDFS - Silver
dadosCli = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/clientes/")
dadosVei = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/veiculos/")
dadosDes = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/despachantes/")
dadosLoc = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/locacao/")
dadosContratos = spark.read.parquet("hdfs://34.151.243.241:9000/datalake/silver/contratos/")

#Transformação dos dados de Negocio
dadosCli.createOrReplaceTempView("clientes")
dadosVei.createOrReplaceTempView("veiculos")
dadosDes.createOrReplaceTempView("despachantes")
dadosLoc.createOrReplaceTempView("locacao")
dadosContratos.createOrReplaceTempView("contratos")

#Veiculos locados em periodos
dadosLocacaoVei = spark.sql (""" SELECT veic.MODELO AS MODELO, YEAR(loc.DATALOCACAO) as ANO, 
MONTH(loc.DATALOCACAO) as MES, COUNT(*) as TOTAL from locacao loc 
JOIN veiculos veic on (veic.IDVEICULO = loc.IDVEICULO) 
GROUP BY veic.MODELO, YEAR(loc.DATALOCACAO), MONTH(loc.DATALOCACAO) 
order by TOTAL DESC
        """)

#Despachantes por locacao e Veiculos
dadosLocacaoDes = spark.sql (""" SELECT desp.IDDESPACHANTE as ID, veic.MODELO AS MODELO, 
YEAR(loc.DATALOCACAO) as ANO, MONTH(loc.DATALOCACAO) as MES, COUNT(loc.TOTAL) as TOTAL 
from locacao loc JOIN veiculos veic on (loc.IDVEICULO = veic.IDVEICULO)  
JOIN despachantes desp on (loc.IDDESPACHANTE = loc.IDDESPACHANTE) 
GROUP BY desp.IDDESPACHANTE, veic.MODELO, YEAR(loc.DATALOCACAO), MONTH(loc.DATALOCACAO) 
order by TOTAL DESC """)

#Faturamento no Periodo
dadosFaturamento = spark.sql (""" SELECT YEAR(loc.DATALOCACAO) as ANO, MONTH(loc.DATALOCACAO) as MES, 
                             SUM(loc.TOTAL) as TOTAL from locacao loc 
                             GROUP BY MONTH(loc.DATALOCACAO), YEAR(loc.DATALOCACAO) order by ANO, MES """)

#Quantidade de Locacao por Clientes - Mensal
dadosLocacaoCli = spark.sql (""" 
        SELECT cli.IDCLIENTE as ID, MONTH(loc.DATALOCACAO) as MES, YEAR(loc.DATALOCACAO) as ANO, count(*) as TOTAL 
        from locacao loc join clientes cli on (cli.IDCLIENTE = loc.IDCLIENTE) 
        GROUP BY cli.IDCLIENTE, MONTH(loc.DATALOCACAO), YEAR(loc.DATALOCACAO) order by cli.IDCLIENTE, ANO, MES 
        """)

#Listagem dos Contratos de Risco
dadosRisco = spark.sql (""" 
        SELECT con.IDCONTRATO AS ID, con.IDCLIENTE as IDCLIENTE from contratos con
        WHERE con.CONTRATO like '%risco%' order by con.IDCONTRATO DESC
        """)

dadosLocacaoCli.coalesce(1)
dadosLocacaoVei.coalesce(1)
dadosLocacaoDes.coalesce(1)
dadosFaturamento.coalesce(1)                             
dadosRisco.coalesce(1)

#Gravacao - Camada GOLD
dadosLocacaoCli.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/gold/locacaoClientes/") 
dadosLocacaoVei.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/gold/locacaoVeiculos/")
dadosLocacaoDes.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/gold/locacaoDespachantes/")
dadosFaturamento.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/gold/faturamento/")
dadosRisco.write.mode("overwrite").parquet("hdfs://34.151.243.241:9000/datalake/gold/contratosRisco/")
