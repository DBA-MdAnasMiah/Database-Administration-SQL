

<p align="center">
  <img src="https://github.com/DBA-MdAnasMiah/Database-Administration-SQL/blob/main/Replications/assets/replication_gif.gif?raw=true" 
       alt="Replication Q/A" width="450" />
</p>

---

## What is SQL Server Replication?
Replication is a process of copying and distributing data and database object from primary server to secondary server.  
Replication enables synchronizing all the data between the Databases to maintain integrity and consistency of the data.

---

## What are the Types of Replications?

### 1. Snapshot Replication
- Snapshot replication distributes data exactly as it appears at a specific moment in time.
- This replication type can be used when data is changed infrequently.
- Point in time copy of objects from one database to another.
- Data are not real time in secondary server (whatever is data modifications are happening in primary server isn’t getting added to the secondary servers right away).
- Unidirectional.

### 2. Transactional Replication
- The Transactional Replication is a procedure to synchronize information from one database (Publisher) to different databases (Subscriber).
- Data are real time (to the secondary servers from the primary servers).
- It replicates each transaction of the published article (database object).
- Server to server solution.
- Unidirectional.

### 3. Peer-to-Peer Replication
- Peer-to-peer replication is used to replicate database data to multiple subscribers at the same time.
- This MS SQL Server replication type can be used when your database servers are distributed across the globe.
- Bidirectional.

### 4. Merge Replication
- It is bidirectional replication that is usually used in server-to-client environments for synchronizing data across database servers when they cannot be connected continuously.
- Merge replication is like transactional replication, but data is replicated from the Publisher to the Subscriber and inversely.
- Synchronized mode.

---

## Common Terms in SQL Replication

- **Publisher** - A publisher is the main server database copy on which publication is configured.
- **Distributor** – Database instance that act.
- **Subscriber** - A subscriber is a database that receives the replicated data from a publication.
- **Articles** – All database object (table, stored procedure, view etc) in publication are called as articles.
- **Publication** – Collection of one or more articles from one database are called publication.
- **Subscription** – Subscription is a request for a copy of a publication that must be delivered to the Subscriber.

---

## What is Publisher?
- Publisher → The main server (source) that has the original database.
- Publication → A collection of selected database objects (like tables, views, procedures) that the Publisher shares with others.
- Publisher sends (publishes) the Publication to other servers (Subscribers).
- The main server/database where the original data lives.

---

## What is a Subscriber?
- A subscriber is the on secondary server database (destination database) that receives the replicated data from a publication.
- That also can be used for reporting purposes.
- Subscriber is secondary server’s database replication of primary server’s database.
- It’s not server level it’s database level.

---

## What is a Distributor?
- The Distributor is a server that contains distribution databases.
- Must have at least one distribution database.

---

## What is a Distribution Database?
- It contains many database objects that keep replicated data information.
- So, it monitors and identifies changes to the articles of its publishers and send the changed data to subscribers.
- If there is any transaction or deletion happens the distributor lets the subscribers to the changes.
- So basically, it maintains the database integrity so both server (publisher & subscriber) changes with the same information.

---

## What is an Article?
- Articles are just database objects on publications.

---

## What is Publication?
- Multiple articles are publication.
- Publication collections of one or more database objects are called publication.

---

## What is Subscription in Replication?
- Subscription is a request for a copy of a publication that must be delivered to the Subscriber.

---

## How Many Types of Subscription Are There?

### Push Subscription
- In the push subscription distributor directly updates the data in the subscriber database.
- Whatever changes happening it will push it to the subscriber database.
- In push subscription distributor is responsible to check the data update then send it to the subscriber from publisher.
- Changed data is forcibly transmitted from a Distributor to the Subscriber database.
- No request from the Subscriber is needed.

### Pull Subscription
- Subscriber is scheduled to check the distributor regularly if any new changes are available, then updates the data in the subscription database itself.
- In pull subscription, subscriber will check the update and changes from distributor regularly and if there are changes then it will apply the changes to the subscription database by itself.
- Requests changes from Publisher.
- Allows the subscriber to pull data as needed.
- The Agent runs on the side of the Subscriber.

---

## What are Agents?
- Agents are MS SQL Server components that can act as background services for relational database management system.
- Used to schedule automated execution of jobs (backup and replication).

---

## What are the 5 Types of Replication Agents?
1. Snapshot Agent  
2. Log Reader Agent  
3. Distribution Agent  
4. Queue Reader Agent  
5. Merge Agent

---

## Where Does the Log Reader Agent Run?
- Log Reader Agent runs continuously from the Distributor Server to scan for new commands marked for replication.

---

## What are the Replication Directions in SQL Server?
- One-way  
- One-to-many  
- Bidirectional  
- Many-to-one
