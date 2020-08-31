# Creating a Data Transformation Pipeline with Cloud Dataprep


Cloud Dataprep by Trifacta is an intelligent data service for visually exploring, cleaning, and preparing structured and unstructured data for analysis. We will explore the Cloud Dataprep UI to build a data transformation pipeline that runs at a scheduled interval and outputs results into BigQuery

The dataset you'll use is an ecommerce dataset that has millions of Google Analytics session records for the Google Merchandise Store loaded into BigQuery.

•	Connect BigQuery datasets to Cloud Dataprep

•	Explore dataset quality with Cloud Dataprep

•	Create a data transformation pipeline with Cloud Dataprep

•	Schedule transformation jobs outputs to BigQuery

![Image of Pipe](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/pipeline1.png)

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

![Image of ecomm](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/ecomm.jpg)


## Exploring ecommerce data fields with a UI

In the right pane, click Add new Recipe.

Click Edit Recipe.

Cloud Dataprep loads a sample of your dataset into the Transformer view. This process might take a few seconds.

![Image of Transformer](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/Transformer.jpg)


Grey bar under totalTransactionRevenue represent missing values for the totalTransactionRevenue field. This means that a lot of sessions in this sample did not generate revenue. Later, we will filter out these values so our final table only has customer transactions and associated revenue.

Maximum timeOnSite in seconds, Maximum pageviews, and Maximum sessionQualityDim for the data sample

![Image of Timeonsite](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/timeonsite.jpg)


•	Maximum Time On Site: 5,561 seconds (or 92 minutes)

•	Maximum Pageviews: 155 pages

•	Maximum Session Quality Dimension: 97


A red bar indicates mismatched values. While sampling data, Cloud Dataprep attempts to automatically identify the type of each column. If you do not see a red bar for the productSKU column, then this means that Cloud Dataprep correctly identified the type for the column (i.e. the String type). If you do see a red bar, then this means that Cloud Dataprep found enough number values in its sampling to determine (incorrectly) that the type should be Integer. Cloud Dataprep also detected some non-integer values and therefore flagged those values as mismatched. In fact, the productSKU is not always an integer (for example, a correct value might be "GGOEGOCD078399"). So in this case, Cloud Dataprep incorrectly identified the column type: it should be a string, not an integer.

 ![Image of red](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/red.jpg)
 
 
 ## Cleaning the data
 
 Clean the data by deleting unused columns, eliminating duplicates, creating calculated fields, and filtering out unwanted rows.
 
 ### Converting the productSKU column data type
 
 To ensure that the productSKU column type is a string data type, open the menu to the right of the productSKU column, then click Change type > String.
 
 
 ### Deleting unused columns
 
 We will be deleting the itemQuantity and itemRevenue columns as they only contain NULL values are not useful
 
 
 ### Deduplicating rows
 
Team has informed you there may be duplicate session values included in the source dataset. Let's remove these with a new deduplicate step.
 
1.	Click the Filter rows icon in the toolbar, then click Remove duplicate rows.

Click Add

Review the recipe 


### Filtering out sessions without revenue

Your team has asked you to create a table of all user sessions that bought at least one item from the website. Filter out user sessions with NULL revenue.

1.	Under the totalTransactionRevenue column, click the grey Missing values bar. All rows with a missing value for totalTransactionRevenue are now highlighted in red.

2.	In the Suggestions panel, in Delete rows , click Add.


![Image of filter](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/filter.jpg)


This step filters your dataset to only include transactions with revenue (where totalTransactionRevenue is not NULL).


### Filtering sessions for PAGE views

The dataset contains sessions of different types, for example PAGE (for page views) or EVENT (for triggered events like "viewed product categories" or "added to cart"). To avoid double counting session pageviews, add a filter to only include page view related hits.

1.	In the histogram below the type column, click the bar for PAGE. All rows with the type PAGE are now highlighted in green.

2.	In the Suggestions panel, in Keep rows, and click Add.


![Image of filter2](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/filter2.jpg)


## Enriching the data


•	visitId: an identifier for this session. This is part of the value usually stored as the utmb cookie. This is only unique to the user. For a completely unique ID, you should use a combination of fullVisitorId and visitId.*

As we see, visitId is not unique across all users. We will need to create a unique identifier.


### Creating a new column for a unique session ID

As you discovered, the dataset has no single column for a unique visitor session. Create a unique ID for each session by concatenating the fullVisitorID and visitId fields.

1.	Click on the Merge columns icon in the toolbar.

2.	For Columns, select fullVisitorId and visitId.

3.	For Separator type a single hyphen character: -

4.	For the New column name, type unique_session_id.

5.	Click Add.

The unique_session_id is now a combination of the fullVisitorId and visitId. We will explore in a later lab whether each row in this dataset is at the unique session level (one row per user session) or something even more granular.


### Creating a case statement for the ecommerce action type

As you saw earlier, values in the eCommerceAction_type column are integers that map to actual ecommerce actions performed in that session. For example, 3 = "Add to Cart" or 5 = "Check out." This mapping will not be immediately apparent to our end users so let's create a calculated field that brings in the value name.

1.	Click on the Conditions icon in the toolbar, then click Case on single column.

2.	For Column to evaluate, specify eCommerceAction_type.

3.	Next to Cases (1), click Add 8 times for a total of 9 cases.


Value to compare	New value:

0	'Unknown'

1	'Click through of product lists'

2	'Product detail views'

3	'Add product(s) to cart'

4	'Remove product(s) from cart'

5	'Check out'

6	'Completed purchase'

7	'Refund of purchase'

8	'Checkout options'




4.	For New column name, type eCommerceAction_label. Leave the other fields at their default values.

5.	Click Add.


### Adjusting values in the totalTransactionRevenue column


As mentioned in the schema, the totalTransactionRevenue column contains values passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). You now divide contents of that column by 10^6 to get the original values.

1.	Open the menu to the right of the totalTransactionRevenue column, then select Calculate > Custom formula.

2.	For Formula, type: DIVIDE(totalTransactionRevenue,1000000) and for New column name, type: totalTransactionRevenue1. Notice the preview for the transformation:

3.	Click Add.

4.	To convert the new totalTransactionRevenue1 column's type to a decimal data type, open the menu to the right of the totalTransactionRevenue1 column by clicking  , then click Change type > Decimal.

5.	Review the full list of steps in your recipe:


![Image of recipe](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/recipe.jpg)



## Running and scheduling Cloud Dataprep jobs to BigQuery


1.	Click Run Job

2.	Hover over the Publishing Actions created and click Edit.

3.	Select BigQuery as a data sink in the left bar

4.	Select your existing ecommerce dataset

5.	Select Create new Table

6.	For Table Name, type revenue_reporting

7.	For options, Truncate the table every run


![Image of publish](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/publish.jpg)


8.	Click Update

9.	Review the setting then Run Job

Once your Cloud Dataprep job is completed (takes 10 - 15 minutes), refresh your BigQuery page and confirm that the output table revenue_reporting exists.

![Image of pipeline2](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/pipeline2.jpg)



You will know your revenue reporting table is ready when the below query successfully executes:

-- generate a report showing the most recent transactions

Refer reporting query

![Image of results](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/results.jpg)


## Creating a scheduled pipeline job

Even if your pipeline is still running, you can also schedule the execution of pipeline in the next step so the job can be re-run automatically on a regular basis to account for newer data.

Note: You can navigate and perform other operations while jobs are running.

1.	You will now schedule a recurrent job execution. Click the Flows icon on the left of the screen.

2.	On the right of your Ecommerce Analytics Pipeline flow click the More icon (...), then click Schedule Flow.

3.	In the Add Schedule dialog:

4.	For Frequency, select Weekly.

5.	For day of week, select Saturday and unselect Sunday.

6.	For time, enter 3:00 and select AM.

7.	Click Save.

The job is now scheduled to run every Saturday at 3AM

IMPORTANT: You will not be able to view your scheduled flows until you setup a scheduled output destination

8.	In your flow, click the output node as shown below:


![Image of job](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/job.jpg)


9.	Under Scheduled Destinations, click Add

10.	In the Scheduled Publishing settings page click Add Publishing Action

11.	Specify an output destination in BigQuery like the one you created previously.


## Monitoring jobs

1.	Click the Jobs icon on the left of the screen.

2.	You see the list of jobs, and wait until your job is marked as Completed.


![Image of joblist](https://github.com/IamVigneshC/DataTransformationPipeline-with-Cloud-Dataprep/blob/master/Resources/joblist.jpg)















