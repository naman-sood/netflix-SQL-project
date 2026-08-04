## Schema

```sql
CREATE TABLE netflix
(
    show_id      VARCHAR(10) PRIMARY KEY,
    type         VARCHAR(20),
    title        VARCHAR(200),
    director     VARCHAR(250),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(20),
    listed_in    VARCHAR(100),
    description  VARCHAR(350)
);
```
