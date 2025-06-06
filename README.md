
# Spring Boot Todo App with MySQL (Dockerized)

This project is a **Spring Boot Todo Application** with a **MySQL** database, containerized using Docker. It allows users to manage tasks in a simple to-do list.

---

## 🧰 Prerequisites

Before you begin, ensure you have the following installed:

- Docker
- Docker Compose
- Java 17+ (only if building outside Docker)
- Git

---

## 📁 Project Structure

```
├── Dockerfile             # Multi-stage build Dockerfile (builds .jar)
├── docker-compose.yml     # Orchestrates app + DB containers
├── .env                   # Environment variables for DB (user-created)
├── src/                   # Source code (Java + resources)
├── pom.xml                # Maven config
└── README.md              # You are here!
```

---

## 🚀 Getting Started

### 1. Clone the Project

```bash
git clone https://github.com/your-username/todo-app-springboot-mysql.git
cd todo-app-springboot-mysql
```

### 2. Create a `.env` File

Create a `.env` file in the project root with your own values:

```
MYSQL_DB=your_db_name
MYSQL_USER=your_username
MYSQL_PASSWORD=your_password
MYSQL_ROOT_PASSWORD=your_root_password
```

> 🔐 **Do not commit this file to version control.**

### 3. Run the App Using Docker Compose

```bash
docker-compose up --build
```

- This builds the Spring Boot app and runs it with MySQL.
- The `.jar` file is created during the build stage (multi-stage Dockerfile).

### 4. Verify the Containers

To check that both containers are running:

```bash
docker ps
```

You should see `todo-app` and `mysql` containers listed.

### 5. Access the Application

- **Local**: [http://localhost:8080](http://localhost:8080)
- **EC2**: `http://<your-ec2-public-ip>:8080`

> Make sure port **8080** is open in your EC2 instance’s security group.

### 6. Access the MySQL Database

Use Docker CLI to connect to MySQL from the running container:

```bash
docker exec -it mysql_container_name mysql -u<MYSQL_USER> -p
```

Once inside MySQL, you can list databases and tables:

```sql
SHOW DATABASES;
USE your_db_name;
SHOW TABLES;
```

---

## ✅ Notes

- App uses a `.jar` file generated by Maven inside Docker (not a `.war`).
- MySQL data persists in a Docker volume.
- DB credentials and names come from the `.env` file and are injected into both the Spring Boot app and the MySQL container.

---

## 📬 Need Help?

If you encounter issues, check logs with:

```bash
docker-compose logs
```

Or check individual containers:

```bash
docker logs <container_id>
```

---

Enjoy building your Dockerized Spring Boot Todo App! 🎉
