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


## Open Cloud Dataprep

## Connecting BigQuery data to Cloud Dataprep

Connect Cloud Dataprep to your BigQuery data source. On the Cloud Dataprep page:

1.	Click Create Flow in the top-right corner.

2.	In the Create Flow dialog, specify these details:

    •	 For Flow Name, type Ecommerce Analytics Pipeline

    • 	For Flow Description, type Revenue reporting table


Click Create

Click Import & Add Datasets.

click BigQuery.

Create dataset 

Import & Add to Flow

![Image of ecomm](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/ecomm.jpg)


## Exploring ecommerce data fields with a UI

In the right pane, click Add new Recipe.

Click Edit Recipe.

Cloud Dataprep loads a sample of your dataset into the Transformer view. This process might take a few seconds.

![Image of Transformer](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Transformer.jpg)


Grey bar under totalTransactionRevenue represent missing values for the totalTransactionRevenue field. This means that a lot of sessions in this sample did not generate revenue. Later, we will filter out these values so our final table only has customer transactions and associated revenue.

Maximum timeOnSite in seconds, Maximum pageviews, and Maximum sessionQualityDim for the data sample

![Image of Timeonsite](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/timeonsite.jpg)


•	Maximum Time On Site: 5,561 seconds (or 92 minutes)

•	Maximum Pageviews: 155 pages

•	Maximum Session Quality Dimension: 97


A red bar indicates mismatched values. While sampling data, Cloud Dataprep attempts to automatically identify the type of each column. If you do not see a red bar for the productSKU column, then this means that Cloud Dataprep correctly identified the type for the column (i.e. the String type). If you do see a red bar, then this means that Cloud Dataprep found enough number values in its sampling to determine (incorrectly) that the type should be Integer. Cloud Dataprep also detected some non-integer values and therefore flagged those values as mismatched. In fact, the productSKU is not always an integer (for example, a correct value might be "GGOEGOCD078399"). So in this case, Cloud Dataprep incorrectly identified the column type: it should be a string, not an integer.

 ![Image of red](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/red.jpg)
 
 
 ## Cleaning the data
 
 Clean the data by deleting unused columns, eliminating duplicates, creating calculated fields, and filtering out unwanted rows.
 
 To ensure that the productSKU column type is a string data type, open the menu to the right of the productSKU column, then click Change type > String.
 
 We will be deleting the itemQuantity and itemRevenue columns as they only contain NULL values are not useful
 
 Team has informed you there may be duplicate session values included in the source dataset. Let's remove these with a new deduplicate step.
 
1.	Click the Filter rows icon in the toolbar, then click Remove duplicate rows.

Click Add

Review the recipe 

Your team has asked you to create a table of all user sessions that bought at least one item from the website. Filter out user sessions with NULL revenue.

1.	Under the totalTransactionRevenue column, click the grey Missing values bar. All rows with a missing value for totalTransactionRevenue are now highlighted in red.

2.	In the Suggestions panel, in Delete rows , click Add.


![Image of filter](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/filter.jpg)










