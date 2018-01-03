# MiscMSSQL
Various MSSQL scripts and tools. Contained herein or linked to for ease of aggregation. Mostly if not all free.

## Scripts
- [Ola's Maintenance Scripts](https://github.com/olahallengren/sql-server-maintenance-solution)
- [Brent's First Responder Kit](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit)
- [Glenn Berry's Diagnostic Queries](https://www.sqlskills.com/blogs/glenn/category/dmv-queries/)
- [Tiger Tool Box](https://github.com/Microsoft/tigertoolbox)
- [sp_WhoIsActive](http://whoisactive.com/downloads/)
- [sp_ForEachDB](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/blob/dev/sp_foreachdb.sql), an [sp_MSForEachDB](http://sqlblog.com/blogs/aaron_bertrand/archive/2010/12/29/a-more-reliable-and-more-flexible-sp-msforeachdb.aspx) replacement.

## References

- [SQL Style Guide](http://www.sqlstyle.guide/)
- [T-SQL Style Guide](https://lowlydba.github.io/tsqlstyle.guide/)
- [DBATools Build Reference](https://sqlcollaborative.github.io/builds)
- [MSSQL Waitopedia](https://www.spotlightessentials.com/public/waitopedia)
- [Module Signing Info](https://modulesigning.info/)

## SSMS Plugins
- [Apex SQL Refactor](http://www.apexsql.com/sql_tools_refactor.aspx)
- [Apex SQL Complete](http://www.apexsql.com/sql_tools_complete.aspx)
- [Apex SQL Search](http://www.apexsql.com/sql_tools_search.aspx)
- [SQL Sentry Plan Explorer](https://www.sentryone.com/plan-explorer/)
- [Dell Spotlight Essentials](https://www.spotlightessentials.com/spotlight-extensions)

## Tools
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Author</th>
  </tr>
  <tr>
    <td><a href="http://www.scalesql.com/isitsql/">Is It SQL?</a></td>
    <td>Monitoring</td>
    <td><a href="http://www.scalesql.com/about.html">Bill Graziano</a></td>
  </tr>
  <tr>
  <td><a href="http://www.methodsandtools.com/tools/dbfit.php">DBFit</a></td>
    <td>Testing</td>
    <td><a href="https://javornikolov.wordpress.com/">Yavor Nikolov</a></td>
  </tr>
  <tr>
  <td><a href="https://github.com/sethreno/schemazen#schemazen---script-and-create-sql-server-objects-quickly">SchemaZen</a></td>
    <td>Scripting</td>
    <td><a href="https://github.com/sethreno">Seth Reno</a></td>
  </tr>
  <tr>
  <td><a href="http://www.red-gate.com/products/dlm/dlm-dashboard/">DLM Dashboard</a></td>
    <td>Devops</td>
    <td>RedGate</td>
  </tr>
  <tr>
  <td><a href="http://sqlfiddle.com/">SQL Fiddle</a></td>
    <td>Testing/Sharing</td>
    <td><a href="http://stackoverflow.com/users/808921/jake-feasel">Jake Feasel</a></td>
  </tr>
  <tr>
  <td><a href="https://www.idera.com/productssolutions/freetools/sqljobmanager">SQL Job Manager</a></td>
    <td>Admin</td>
    <td>Idera</td>
  </tr>
  <tr>
  <td><a href="http://www.manduka.tech/#/home">SQL Code Analyzer</a></td>
    <td>Development</td>
    <td>Manduka</td>
  </tr>
  <tr>
  <td><a href="https://github.com/Microsoft/sql-xplat-cli/">mssql-scripter</a></td>
    <td>Scripting</td>
    <td>Microsoft</td>
  </tr>
  <tr>
  <td><a href="http://sqlfiddle.com/">DBA Tools Powershell Scripts</a></td>
    <td>Admin</td>
    <td><a href="https://dbatools.io/team/">DBA Tools Team</a></td>
  </tr>
    <tr>
  <td><a href="https://flywaydb.org/">Flyway</a></td>
    <td>Migrations</td>
    <td><a href="https://axelfontaine.com/">Axel Fontaine</a></td>
  </tr>
  <tr>
    <td><a href="https://pastetheplan.com/">Paste The Plan</a></td>
    <td>Tuning/Sharing</td>
    <td><a href="https://www.brentozar.com/">Brent Ozar Unlimited</a></td>
  </tr>
</table>

## Other
- [Wide World Importer Database](https://github.com/Microsoft/sql-server-samples) - Successor to the AdventureWorks sample database for SQL 2016+
- [Stack Overflow Database](https://www.brentozar.com/archive/2017/07/new-stack-overflow-public-database-available-2017-06/) - Brent Ozar's packaging of the 2017 Stack Overflow database for demoing and testing
- [idownvotedbecau.se](http://idownvotedbecau.se/) - Pages containing downvoting rationale for adding to Stack Exchange comments.

## Good Reads
- [Modern Data Analysis: Don't Trust Your Spreadsheet][betterment]
- [T-SQL Interview Questions](https://www.mssqltips.com/sqlservertip/1450/sql-server-developer-tsql-interview-questions/) by [Jeremy Kadlec](https://www.mssqltips.com/sqlserverauthor/38/jeremy-kadlec/)
- [Developer Interview Questions](https://www.brentozar.com/archive/2009/06/top-10-developer-interview-questions-about-sql-server/) by Brent Ozar
- [Tuning Cost Threshold](http://sqlblog.com/blogs/jonathan_kehayias/archive/2010/01/19/tuning-cost-threshold-of-parallelism-from-the-plan-cache.aspx)
- [5 Rules of Normalization][normrules] by Marc Rettig
- [T-SQL Code Smells][smelly] by [Phil Factor][phil]
- [Fighting Evil in Your Code: Comments on Comments](https://www.red-gate.com/simple-talk/opinion/opinion-pieces/fighting-evil-code-comments-comments/) by [Michael Sorens](https://www.red-gate.com/simple-talk/author/michael-sorens/)


[betterment]: https://www.betterment.com/resources/inside-betterment/engineering/modern-data-analysis-dont-trust-your-spreadsheet/
  "Betterment Blog"
[isitsql]: http://www.scalesql.com/isitsql/
  "Is It SQL?"
[schemazen]: https://github.com/sethreno/schemazen#schemazen---script-and-create-sql-server-objects-quickly
  "SchemaZen"
[dbfit]: http://www.methodsandtools.com/tools/dbfit.php
  "DB Fit"
[fiddle]: http://sqlfiddle.com/
  "SQL Fiddle"
[normrules]: https://github.com/LowlyDBA/miscmssql/blob/master/Best%20Practices/Marc_Rettig_5_Rules_of_Normalization_Poster.pdf
  "5 Rules of Normalization"
 [smelly]: https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-code-smells/
 [phil]: https://www.red-gate.com/simple-talk/author/phil-factor/
