#!/usr/bin/env python
# coding: utf-8

#Import
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql import functions as F
from pyspark.sql.types import *
from datetime import datetime

import warnings
warnings.filterwarnings("ignore")

# Cria a sessão Spark
spark = SparkSession.builder.appName('pipeline-stream-send').master("local").getOrCreate()

dados = [
    {"idcliente":"1","idcontrato":"664299","datacadastro":"30/05/2022","contrato":"CONTRATO DE LOCAÇÃO DE AUTOMÓVEL DE PRAZO DETERMINADO IDENTIFICAÇÃO DAS PARTES CONTRATANTES LOCADORA: RoboCar Tipo de Contrato: normal LOCATÁRIO: (Nome do Locatário)As partes acima identificadas têm, entre si, justo e acertado o presente Contrato de Locação de Automóvel de Prazo Determinado, que se regerá pelas cláusulas seguintes e pelas condições descritas no presente. DO OBJETO DO CONTRATO Cláusula 1ª. O presente contrato tem como OBJETO a locação1 do automóvel de propriedade da LOCADORA. DO USO Cláusula 2ª. O automóvel, objeto deste contrato, será utilizado exclusivamente pelo LOCATÁRIO, não sendo permitido o seu uso por terceiros sob pena de rescisão contratual e o pagamento da multa prevista na Cláusula 7ª.DA DEVOLUÇÃO Cláusula 3ª. O LOCATÁRIO deverá devolver o automóvel à LOCADORA nas mesmas condições em que estava quando o recebeu, ou seja, em perfeitas condições de uso, respondendo pelos danos ou prejuízos causados.Cláusula 5ª. Se o LOCATÁRIO não restituir o automóvel na data estipulada, deverá pagar, enquanto detiver em seu poder, o aluguel que a LOCADORA arbitrar, e responderá pelo dano, que o automóvel venha a sofrer mesmo se proveniente de caso fortuito3.DA RESCISÃO Cláusula 6ª. É assegurado às partes a rescisão do presente contrato a qualquer momento, desde que haja comunicação à outra parte com antecedência mínima de 2 dias.Cláusula 7ª. O descumprimento de qualquer das cláusulas por parte dos contratantes ensejará a rescisão deste instrumento e o devido pagamento de multa, pela parte inadimplente no valor de R$ 5000, Por estarem assim justos e contratados, firmam o presente instrumento, em duas vias de igual teor, juntamente com 2 (duas) testemunhas."}
]
df = spark.createDataFrame(dados)
df_json = (df.select(to_json(struct(col("*"))).alias("value")))
df_json.write.format("kafka").option("kafka.bootstrap.servers", "34.151.219.59:9092").option("topic", "engdados-stream").save()

