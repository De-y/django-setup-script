Write-Output "
________       __                              
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

Powered by Python, Django, and PowerShell. Contains virtual environment setup inside, no need to build a virtual environment first.
"

# Define the project and app names
$projectName = Read-Host "What do you want to call the project?"
$appName = Read-Host "What do you want to call the appname?"

# Create a new Python virtual environment
python -m venv venv

# Activate the virtual environment
.\venv\Scripts\Activate.ps1

# Install Django
pip install django

# Create a new Django project
django-admin startproject $projectName

# Navigate into the project directory
cd $projectName

# Create a new Django app
python manage.py startapp $appName

# Create a new database migration
python manage.py makemigrations

# Apply the database migration
python manage.py migrate

# Create templates directory and add index.html file
mkdir templates
Set-Content -Path "templates/index.html" -Value '<html><body><h1>Hello, world!</h1></body></html>'

# Create ClassView in myapp/views.py
Set-Content -Path "${appName}/views.py" -Value @"
from django.views.generic import TemplateView

class IndexView(TemplateView):
    template_name = 'index.html'
"@

# Update urls.py to include the ClassView
(Get-Content -Path "${projectName}/urls.py") | Foreach-Object {
    if ($_ -match "from django.urls import path") {
        $_ + "`nfrom ${appName}.views import IndexView`n"
    } elseif ($_ -match "urlpatterns = \[") {
        $_ + "`n    path('', IndexView.as_view(), name='home'),`n"
    } else {
        $_
    }
} | Set-Content -Path "${projectName}/urls.py"

# Update settings.py to include the templates directory
(Get-Content -Path "${projectName}/settings.py") | Foreach-Object {
    if ($_ -match "'APP_DIRS': True,") {
        $_ -replace "'APP_DIRS': True,", "'APP_DIRS': True,`n        'DIRS': ['templates'],`n"
    } else {
        $_
    }
} | Set-Content -Path "${projectName}/settings.py"

# Update the URL pattern to use the new template
$urlPattern = @"
from django.urls import path
from .views import IndexView

urlpatterns = [
    path('', IndexView.as_view(template_name='index.html'), name='home'),
]
"@
Set-Content -Path ".\${appName}\urls.py" -Value $urlPattern

Write-Output "Done! Your project is ready to go."

Write-Output "Running the development server for now. You can access it at http://localhost:8000"
Write-Output "In the future, don't forget to activate the virtual environment first by running '.\venv\Scripts\Activate.ps1' and then run 'python manage.py runserver' to start the development server."
# Start the development server
python manage.py runserver
