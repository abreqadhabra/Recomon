package com.abreqadhabra.examples.recomon.spark;

import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.ml.recommendation.ALS;
import org.apache.spark.ml.recommendation.ALSModel;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.storage.StorageLevel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.*;

import static org.apache.spark.sql.functions.col;

public class ALSExample {

  private static final Logger log = LoggerFactory.getLogger(ALSExample.class);

  public static void main(String[] args) {

    //  hadoop binary path
    System.setProperty("hadoop.home.dir", "C:/Recomon/hadoop-2.6.0");

    SparkSession spark = SparkSession.builder().master("local[*]").appName("ALSExample")
                                     .config("spark.ui.enabled", "false")
                                     .config("spark.sql.crossJoin.enabled", "true")
                                     .config("spark.sql.shuffle.partitions", "8").getOrCreate();
    JavaSparkContext jsc = JavaSparkContext.fromSparkContext(spark.sparkContext());

    Path trainingFilePath = Paths.get("data/train_recomon.csv");

    //Load Datasets test_recomon.csv
    Dataset<Row> training =
      spark.read().format("csv").option("header", "true").option("inferSchema", "true")
           .load(trainingFilePath.toString()).persist(StorageLevel.MEMORY_ONLY());

    if (log.isTraceEnabled()) {
      training.show();
      training.printSchema();
      log.trace("training:{}", training.count());
    }

    Path testFilePath = Paths.get("data/test_recomon.csv");

    Dataset<Row> test =
      spark.read().format("csv").option("header", "true").option("inferSchema", "true")
           .load(testFilePath.toString()).persist(StorageLevel.MEMORY_ONLY());

    if (log.isTraceEnabled()) {
      test.show();
      test.printSchema();
      log.trace("test:{}", test.count());
    }

    // Build the recommendation model using ALS on the training data
    ALS als = new ALS().setMaxIter(5).setRegParam(0.01).setUserCol("ID").setUserCol("user")
                       .setItemCol("movie").setRatingCol("rating");
    ALSModel model = als.fit(training);

    // Evaluate the model by computing the RMSE on the test data
    Dataset<Row> predictions = model.transform(test);

    if (log.isTraceEnabled()) {
      predictions.show();
      predictions.printSchema();
      log.trace("predictions:{}", predictions.count());
    }

    Dataset<Row> result = predictions.select(col("ID"), col("prediction").alias("rating"));

    if (log.isTraceEnabled()) {
      predictions.show();
      predictions.printSchema();
      log.trace("predictions:{}", predictions.count());
    }
/*
    RegressionEvaluator evaluator =
      new RegressionEvaluator().setMetricName("rmse").setLabelCol("rating")
                               .setPredictionCol("prediction");
    Double rmse = evaluator.evaluate(predictions);
    log.trace("RMSE(Root Mean Square Error):{}" + rmse);
*/

    Path resultPath = Paths.get("data/result");

    if (Files.exists(resultPath)) {
      try {
        Files.delete(resultPath);
        result.coalesce(1).write().format("csv").save(resultPath.toString());
      } catch (NoSuchFileException x) {
        System.err.format("%s: no such" + " file or directory%n", resultPath);
      } catch (DirectoryNotEmptyException x) {
        System.err.format("%s not empty%n", resultPath);
      } catch (IOException x) {
        System.err.println(x);
      }
    }

    spark.stop();
  }
}
