#!/bin/bash

echo '________       __                              
\______ \     |__|____    ____    ____   ____  
 |    |  \    |  \__  \  /    \  / ___\ /  _ \ 
 |    `   \   |  |/ __ \|   |  \/ /_/  >  <_> )
/_______  /\__|  (____  /___|  /\___  / \____/ 
        \/\______|    \/     \//_____/         
  _________       __                           
 /   _____/ _____/  |_ __ ________             
 \_____  \_/ __ \   __\  |  \____ \            
 /        \  ___/|  | |  |  /  |_> >           
/_______  /\___  >__| |____/|   __/            
        \/     \/           |__|               
  _________            .__        __           
 /   _____/ ___________|__|______/  |_         
 \_____  \_/ ___\_  __ \  \____ \   __\        
 /        \  \___|  | \/  |  |_> >  |          
/_______  /\___  >__|  |__|   __/|__|          
        \/     \/         |__|                                                                     
By @de-y

Powered by Python, Django, and PowerShell. Contains virtual environment setup inside, no need to build a virtual environment first.'

echo "<!> This script has errors whilst compiling the pages, this will be fixed in a future commit, but the script will still work for creating the project. <!>"

# Define the project and app names
read -p "What do you want to call the project? " projectName
read -p "What do you want to call the appname? " appName

echo "Alright, let's get started!"

echo 'Creating a new Python virtual environment...'

# Create a new Python virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

echo 'Installing Django...'

# Install Django
pip install django

echo 'Creating a new Django project...'
# Create a new Django project
django-admin startproject $projectName

echo 'Creating a new Django app...'
# Navigate into the project directory
cd $projectName

# Create a new Django app
python manage.py startapp $appName

# Create a new database migration
python manage.py makemigrations

# Apply the database migration
python manage.py migrate

echo 'Setting up the Django project...'
# Create templates directory and add index.html file
mkdir templates
echo "<html><body><h1>Hello, world!</h1></body></html>" > templates/index.html

# Create ClassView in myapp/views.py
cat <<EOF > "${appName}/views.py"
from django.views.generic import TemplateView

class IndexView(TemplateView):
    template_name = 'index.html'
EOF

# Update urls.py to include the ClassView
awk '{
    if ($0 ~ /from django.urls import path/) {
        print $0 "\nfrom '"$appName"'.views import IndexView"
    } else if ($0 ~ /urlpatterns = \[/) {
        print $0 "\n    path('', IndexView.as_view(), name='home'),"
    } else {
        print $0
    }
}' "${projectName}/urls.py" > "${projectName}/urls_new.py"
mv "${projectName}/urls_new.py" "${projectName}/urls.py"

# Update settings.py to include the templates directory
awk '{
    if ($0 ~ /'APP_DIRS': True,/) {
        print $0 "\n        'DIRS': ['templates'],"
    } else {
        print $0
    }
}' "${projectName}/settings.py" > "${projectName}/settings_new.py"
mv "${projectName}/settings_new.py" "${projectName}/settings.py"

# Update the URL pattern to use the new template
urlPattern=$(cat <<EOF
from django.urls import path
from .views import IndexView

urlpatterns = [
    path('', IndexView.as_view(template_name='index.html'), name='home'),
]
EOF
)
echo "$urlPattern" > "${appName}/urls.py"

echo 'We are done with the setup!'

echo 'Starting the development server...'
# Start the development server
python manage.py runserver
