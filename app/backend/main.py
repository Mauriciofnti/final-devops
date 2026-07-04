from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# Puxa a URL do banco de dados do arquivo YAML, ou usa um padrão
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "postgresql://taskflow_user:taskflow_pass@postgres-service:5432/taskflow_db"
)

# Configuração do SQLAlchemy
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Modelo do Banco de Dados
class TaskDB(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)

# Cria as tabelas no banco automaticamente
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Evita erros de CORS entre o Frontend e o Backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TaskCreate(BaseModel):
    title: str

@app.get("/")
def read_root():
    return {"status": "Backend rodando!"}

@app.get("/tasks")
def get_tasks():
    db = SessionLocal()
    tasks = db.query(TaskDB).all()
    db.close()
    return tasks

@app.post("/tasks")
def create_task(task: TaskCreate):
    db = SessionLocal()
    db_task = TaskDB(title=task.title)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    db.close()
    return db_task