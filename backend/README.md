## Instalación

1. Crear ambiente virtual
    1. Instalar _virtualenv_ **pip install virtualenv**
    2. Crear ambiente **virtualenv env**
    3. Conectarse al ambiente virtual **source env/bin/activate** 
        (Buscar comando específico para windows)
    
2. Instalar librerías
Con el ambiente corriendo (Se debe ver _(env)_ al principio de la terminal)
ejecutar **pip install -r requirements**

3. Migrar base de datos
Está configurada con sqlite, por lo que solo es necesario hacer migraciones
- **python manage.py makemigrations**
- **python manage.py migrate**

## Ejecución

Para ejecutar **python manage.py runserver**
