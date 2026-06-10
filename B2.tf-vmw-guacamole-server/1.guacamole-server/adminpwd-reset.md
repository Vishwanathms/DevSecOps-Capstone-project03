# Apache Guacamole - Reset guacadmin Password (MySQL Backend)

## Prerequisites

* Access to the MySQL container
* MySQL root credentials
* Apache Guacamole configured with MySQL authentication

---

# Step 1: Connect to the MySQL Container

Identify the MySQL container:

```bash
docker ps
```

Connect to the container:

```bash
docker exec -it <mysql-container-name> mysql -u root -p
```

Enter the MySQL root password when prompted.

---

# Step 2: Select the Guacamole Database

```sql
USE guacamole_db;
```

Verify the database is selected successfully.

Expected Output:

```text
Database changed
```

---

# Step 3: Identify Existing Guacamole Users

In newer Guacamole versions, usernames are stored in the `guacamole_entity` table.

Execute:

```sql
SELECT
    u.user_id,
    u.entity_id,
    e.name
FROM guacamole_user u
JOIN guacamole_entity e
ON u.entity_id = e.entity_id;
```

Example Output:

```text
+---------+-----------+-----------+
| user_id | entity_id | name      |
+---------+-----------+-----------+
| 1       | 1         | guacadmin |
+---------+-----------+-----------+
```

---

# Step 4: Reset the guacadmin Password

Replace `NewPassword123` with your desired password.

```sql
UPDATE guacamole_user u
JOIN guacamole_entity e
ON u.entity_id = e.entity_id
SET
    u.password_hash = UNHEX(SHA2('NewPassword123',256)),
    u.password_salt = NULL,
    u.password_date = NOW(),
    u.disabled = 0,
    u.expired = 0
WHERE e.name = 'guacadmin';
```

Expected Output:

```text
Query OK, 1 row affected
```

---

# Step 5: Verify Account Status

Confirm that the account is enabled and not expired.

```sql
SELECT
    e.name,
    u.disabled,
    u.expired
FROM guacamole_user u
JOIN guacamole_entity e
ON u.entity_id = e.entity_id
WHERE e.name='guacadmin';
```

Expected Output:

```text
+-----------+----------+---------+
| name      | disabled | expired |
+-----------+----------+---------+
| guacadmin | 0        | 0       |
+-----------+----------+---------+
```

Where:

* disabled = 0 → Account enabled
* expired = 0 → Password active

---

# Step 6: Exit MySQL

```sql
EXIT;
```

---

# Troubleshooting

## List All Users

```sql
SELECT
    e.name,
    u.user_id
FROM guacamole_user u
JOIN guacamole_entity e
ON u.entity_id = e.entity_id;
```

## View Complete User Details

```sql
SELECT
    e.name,
    u.*
FROM guacamole_user u
JOIN guacamole_entity e
ON u.entity_id = e.entity_id;
```

## Verify Guacamole Container Logs

```bash
docker logs guacamole
```

## Verify MySQL Container Logs

```bash
docker logs <mysql-container-name>
```

---

# Security Recommendation

After successfully logging in:

1. Login as `guacadmin`
2. Create a new administrative user
3. Disable or delete the default `guacadmin` account if not required
4. Store credentials in a secure password manager
