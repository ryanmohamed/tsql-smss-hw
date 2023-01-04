/*
Ryan Mohamed
23671523

Single Table Queries - Exercises

**Here we see the conversion of the TSQLV4 db queries to Pascal Case naming convention (kind of like camel cased) in NorthWinds...**
*/

use TSQLV4
go
select * from hr.Employees

use Northwinds2022TSQLV7
go
select * from HumanResources.Employee

/*
# `QUERY 1) Return orders placed in June 2015`

### `TABLES INVOLVED) Sales.Order`

```
orderid     orderdate  custid      empid
----------- ---------- ----------- -----------
10555       2015-06-02 71          6
10556       2015-06-03 73          2
10557       2015-06-03 44          9
10558       2015-06-04 4           1
10559       2015-06-05 7           6
10560       2015-06-06 25          8
10561       2015-06-06 24          2
10562       2015-06-09 66          1
10563       2015-06-10 67          2
10564       2015-06-10 65          4

```
```
(30 row(s) affected)

```
*/

use Northwinds2022TSQLV7
go 

select OrderId as orderid, 
    OrderDate as orderdate,
    CustomerId as custid,
    EmployeeId as empid
from Sales.[Order]
where YEAR(OrderDate) = 2015 and MONTH(OrderDate) = 6
order by orderid, orderdate, custid, empid
 


/*
# `QUERY 2) Return orders placed on the last day of the month`

### `TABLES INVOLVED) tsqlv4 db, Sales.Order`

```
orderid     orderdate  custid      empid
----------- ---------- ----------- -----------
10269       2014-07-31 89          5
10317       2014-09-30 48          6
10343       2014-10-31 44          4
10399       2014-12-31 83          8
10432       2015-01-31 75          3
10460       2015-02-28 24          8
10461       2015-02-28 46          1
10490       2015-03-31 35          7
10491       2015-03-31 28          8
10522       2015-04-30 44          4

```
```
(26 row(s) affected)

```
*/

use Northwinds2022TSQLV7
go

select OrderId as orderid,
    OrderDate as orderdate, 
    CustomerId as custid,
    EmployeeId as empid 
from Sales.[Order]
where EOMONTH(OrderDate) = OrderDate
order by orderid, orderdate, custid, empid

/*
# `QUERY 3)` Return employees with last name containing the letter 'e' twice or more

### `TABLES INVOLVED) HR.Employees`\`

```
empid       firstname  lastname
----------- ---------- --------------------
4           Yael       Peled
5           Sven       Mortensen

```
```
(2 row(s) affected)
```
*/

use Northwinds2022TSQLV7
go 

select EmployeeId as empid,
    EmployeeFirstName as firstname,
    EmployeeLastName as lastname
from HumanResources.[Employee]
where EmployeeLastName LIKE N'%e%e%'
order by empid, firstname, lastname

/*
# `QUERY 4)` Return orders with total value(qty\*unitprice) greater than 10000, sorted by total value

### `TABLES INVOLVED) Sales.OrderDetails`

`
```
orderid     totalvalue
----------- ---------------------
10865       17250.00
11030       16321.90
10981       15810.00
10372       12281.20
10424       11493.20
10817       11490.70
10889       11380.00
10417       11283.20
10897       10835.24
10353       10741.60
10515       10588.50
10479       10495.60
10540       10191.70
10691       10164.80
```
```
(14 row(s) affected)
```
`
*/

use Northwinds2022TSQLV7
go 

select OrderId as orderid,
    --sum all total order prices for the order id
    SUM(Quantity * UnitPrice) as totalvalue 
from Sales.[OrderDetail]
--cant have this here, should be a having clause, no aggregate in WHERE unless its a subquery
--where SUM(Quantity * UnitPrice) > 10000.00

--orderid cant be in the select statement alone now that we have an aggregate,
--  because we'd be returning the same value multiple times for the same orderid
--hence the reason we should group our table by distinct orderids
group by orderid

--but we only want totalvalues > 10000! and recall why this instead of having
having SUM(Quantity * UnitPrice) > 10000

--we dont want it in that order so...
--and we can do this because our alias is now understood by the parser
order by totalvalue desc








/*
# `QUERY 5)` Write a query against the HR.Employees table that returns employees with a last name that starts with a lower case letter. Remember that the collation of the sample database is case insensitive (Latin1\_General\_CI\_AS). For simplicity, you can assume that only English letters are used in the employee last names.

### `TABLES INVOLVED) Sales.OrderDetails`

\`

```
empid       lastname
----------- --------------------

```
```
(0 row(s) affected)

```

\`
*/

use Northwinds2022TSQLV7
go

select EmployeeId as empid,
    EmployeeLastName as lastname
from HumanResources.Employee

--collate is our set of character and character encoding rules
--  we can change how data is matched using it in comparison statement
--  here we change our rules from CI to CS (case sensitive)
where LEFT(EmployeeLastName, 1) COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%'

/*
# `QUERY 6)` Explain the difference between the following 2 queries
*/

use TSQLV4
go 

--Query 1
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;

--test
-- SELECT empid, orderdate
-- FROM Sales.Orders
-- WHERE empid = 1
-- order by orderdate

--this query returns rows of individual empids (not found in more than one row as provided by GROUP BY)
    --and num of orders BEFORE 20160501 simply

-- Query 2
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501';

--test
-- SELECT empid, COUNT(*) AS numorders, MAX(orderdate) as maxorderdate
-- FROM Sales.Orders
-- GROUP BY empid

-- ** recall we must group by for unique empid column cells, since we're using an aggregate
-- ** recall aggregate functions like max cant be in WHERE, only HAVING

--this query returns rows of individ empis, and num of orders, of ONLY the empids
-- with a MOST RECENT orderdate BEFORE than 20160501

-- ** most simply the main difference between these queries is that 
-- QUERY 1 returns ALL empids and their number of orders before May 1st 2016
-- QUERY 2 returns only the empids with a MOST RECENT order before May 1st 2016

-- their PascalCaseConvention equivalent would be..

use Northwinds2022TSQLV7

--query 1
select EmployeeId as empid,
    COUNT(*) as numorders
from Sales.[Order]
where OrderDate < '20160501'
group by EmployeeId
order by EmployeeId --not entirely necessary

--query 2
select EmployeeId as empid,
    COUNT(*) as numorders
from Sales.[Order]
group by EmployeeId
having MAX(OrderDate) < '20160501'

/*
# `QUERY 7)` Return the three ship countries with the highest average freight for orders placed in 2015

### `TABLES INVOLVED) Sales.Orders`

```
shipcountry     avgfreight
--------------- ---------------------
Austria         178.3642
Switzerland     117.1775
Sweden          105.16

```
```
(3 row(s) affected)

```
*/

use Northwinds2022TSQLV7
go

select top 3 ShipToCountry as shipcountry,
    AVG(Freight) as avgfreight
from Sales.[Order]
where YEAR(OrderDate) = 2015 --initally thought this wouldn't work, but YEAR is not an aggregate, it simply works on a datestring, not rows of cells
group by ShipToCountry
order by avgfreight desc -- got an error with top 3, bc first we have to order it by highest avgfreight

/*
# `QUERY 8)` Calculate row numbers for orders based on order date ordering (using order id as tiebreaker) for each customer separately

### `TABLES INVOLVED) Sales.Orders`

```
custid      orderdate  orderid     rownum
----------- ---------- ----------- --------------------
1           2015-08-25 10643       1
1           2015-10-03 10692       2
1           2015-10-13 10702       3
1           2016-01-15 10835       4
1           2016-03-16 10952       5
1           2016-04-09 11011       6
2           2014-09-18 10308       1
2           2015-08-08 10625       2
2           2015-11-28 10759       3
2           2016-03-04 10926       4
```
```
(830 row(s) affected)
```
*/

use Northwinds2022TSQLV7
go 

select CustomerId as custid,
    OrderDate as orderdate,
    OrderId as orderid,
    ROW_NUMBER() over (partition by CustomerId order by orderdate, orderid) as rownum
from Sales.[Order]

/*
# `QUERY 9)` Figure out and return for each employee the gender based on the title of courtesy Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown

### `TABLES INVOLVED) HR.Employees`

```
empid       firstname  lastname             titleofcourtesy           gender
----------- ---------- -------------------- ------------------------- -------
1           Sara       Davis                Ms.                       Female
2           Don        Funk                 Dr.                       Unknown
3           Judy       Lew                  Ms.                       Female
4           Yael       Peled                Mrs.                      Female
5           Sven       Mortensen            Mr.                       Male
6           Paul       Suurs                Mr.                       Male
7           Russell    King                 Mr.                       Male
8           Maria      Cameron              Ms.                       Female
9           Patricia   Doyle                Ms.                       Female

```
```
(9 row(s) affected)
```
*/

use Northwinds2022TSQLV7
go

select EmployeeId as empid, 
    EmployeeFirstName as firstname, 
    EmployeeLastName as lastname, 
    EmployeeTitleOfCourtesy as titleofcourtesy,

case EmployeeTitleOfCourtesy
    when 'Ms.' then 'Female'
    when 'Mrs.' then 'Female'
    when 'Mr.' then 'Male'
    when 'Dr.' then 'Unknown'
    else 'Unknown'
end as gender

from HumanResources.Employee

order by empid

/*
# `QUERY 10)` Return for each customer the customer ID and region 

# Sort the rows in the output by region having NULLs sort last (after non-NULL values)

# Note that the default in T-SQL is that NULLs sort first

### `TABLES INVOLVED) Sales.Customers`

```
custid      region
----------- ---------------
55          AK
10          BC
42          BC
45          CA
37          Co. Cork
33          DF
71          ID
38          Isle of Wight
46          Lara
78          MT
...
1           NULL
2           NULL
3           NULL
4           NULL
5           NULL
6           NULL
7           NULL
8           NULL
9           NULL
11          NULL

```
```
(91 row(s) affected)

```
*/

use Northwinds2022TSQLV7
go 

select CustomerId as custid,
    CustomerRegion as region
from Sales.[Customer]
order by
    case --this is our own ordering scheme, notice when we change 1 to a value < 0 it changes the order
        when CustomerRegion is null then 1
        else 0 
    end, region, custid --this gurantees order at the end, so all nulls are ordered by id