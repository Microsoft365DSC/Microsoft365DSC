# Generating Reports

Microsoft365DSC makes it very easy to generate user-friendly reports from any configuration, whether you wrote it yourself or generated it using the configuration snapshot feature. The solution allows you to generate CSV, HTML, Excel, Markdown and JSON reports from existing files.

> **NOTE:** To generate Excel reports, you need to have Office installed on the machine on which you are trying to generate the report.

## Generate Report

To generate reports, simply use the <a href="../../cmdlets/New-M365DSCReportFromConfiguration/">New-M365DSCReportFromConfiguration</a> cmdlet and specify what type of report you want using the **Type** parameter (CSV, HTML, Excel, Markdown or JSON). The cmdlet also requires you to specify the full path to the .ps1 configuration file you want to generate the report from using the **-ConfigurationPath** parameter, and specify where you wish to store the generated report using the **-OutputPath** parameter.

## CSV Report

The CSV report is a list of resources and its properties, similar to the Excel report below. The difference is that there are no colors and the resources are separated by horizontal lines.

<figure markdown>
  ![Generating a CSV report](../../Images/GenerateCsvReport.png)
  <figcaption>Generating a CSV report</figcaption>
</figure>

## Excel Report

Generating an Excel report from a configuration will automatically launch the Excel client as part of the process. Users will see data being loaded progressively into the workbook, and once the generation process has finished, the columns will automatically be resized to fit the content. The report will also automatically format the key mandatory parameter (e.g. primary key) of each resource in **bold** and apply some styling on the output.

<figure markdown>
  ![Generating an Excel report](../../Images/GenerateExcelReport.png)
  <figcaption>Generating an Excel report</figcaption>
</figure>

## HTML Report

Generating an HTML report works slightly differently. The **New-M365DSCReportFromConfiguration** cmdlet will create the report file at the location specified by the **OutputPath** parameter, but it won’t actually launch the report for display in a browser. The cmdlet, when used for HTML reports, will also return the raw HTML content of the report as shown in the image below.

<figure markdown>
  ![Generating an HTML report](../../Images/CommandToGenerateHTMLReport.png)
  <figcaption>Generating an HTML report</figcaption>
</figure>

<figure markdown>
  ![Example of HTML report](../../Images/ExampleOfHTMLReport.png)
  <figcaption>Example of HTML report</figcaption>
</figure>

## Markdown Report

The Markdown report lists every resource instance of a configuration with the properties the configuration sets and their values. By default the whole configuration lands in a single document.

Add the **-SplitByResource** parameter to write one document per resource instance instead. Those documents are placed in a folder per workload below **-OutputPath**.

By default a document carries the name, data type and value of every property the configuration sets. Add the **-IncludeAllInformation** parameter to list every property the resource supports, set or not, together with its attribute, allowed values and description, and the permissions the resource requires.

> **NOTE:** A split report deletes the Markdown files of the workload folders it writes. That keeps instances which no longer exist from lingering. Other files, and Markdown files elsewhere in the folder, are kept. Point **-OutputPath** at a folder that is used for this report only.

```powershell
New-M365DSCReportFromConfiguration -Type 'Markdown' -ConfigurationPath 'C:\DSC\ConfigName.ps1' -OutputPath 'C:\DSC\M365Report.md'

New-M365DSCReportFromConfiguration -Type 'Markdown' -ConfigurationPath 'C:\DSC\ConfigName.ps1' -OutputPath 'C:\DSC\Report' -SplitByResource -IncludeAllInformation
```

## JSON Report

The JSON report is the report type that can be consumed by other applications. It contains all resources and its instances, with all properties that can be interpreted by other apps. While the other report types are made to be human-readable, this report type is intended to be machine-readable. Due to the nature of JSON, it's still easily readable and very similar to the actual configuration.

<figure markdown>
  ![Example of JSON report](../../Images/ExampleOfJsonReport.png)
  <figcaption>Example of JSON report</figcaption>
</figure>
