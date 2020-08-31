# Creating a Data Transformation Pipeline with Cloud Dataprep


Cloud Dataprep by Trifacta is an intelligent data service for visually exploring, cleaning, and preparing structured and unstructured data for analysis. We will explore the Cloud Dataprep UI to build a data transformation pipeline that runs at a scheduled interval and outputs results into BigQuery

The dataset you'll use is an ecommerce dataset that has millions of Google Analytics session records for the Google Merchandise Store loaded into BigQuery.

•	Connect BigQuery datasets to Cloud Dataprep

•	Explore dataset quality with Cloud Dataprep

•	Create a data transformation pipeline with Cloud Dataprep

•	Schedule transformation jobs outputs to BigQuery

![Image of Pipe](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/pipeline1.png)

We need BigQuery as an endpoint for dataset ingestion to the pipeline and as a destination for the output when the pipeline is completed.


## Creating a BigQuery Dataset

Create a new BigQuery dataset to receive the output table of your new pipeline.
CREATE DATASET

•	For Dataset ID, type ecommerce.

## Create table

` CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_dataprep `

 ` OPTIONS( `
 
   ` description="Raw data from analyst team to ingest into Cloud Dataprep" `
   
 ` ) AS `
 
 ` SELECT * FROM data-to-insights.ecommerce.all_sessions_raw `
 
 ` WHERE date = '20170801'; # limiting to one day of data 56k rows `



