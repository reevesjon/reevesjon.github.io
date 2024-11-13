from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from flask import jsonify
from werkzeug.security import check_password_hash, generate_password_hash
import secrets
import decimal
from datetime import datetime, date

app = Flask(__name__)
app.secret_key = secrets.token_hex(16)  # Generates a random 32-character hex string

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:Pr0j3ctB33h1v3@localhost/4050_test'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

#Association table for task_assignment:
task_assignments = db.Table(
    'task_assignments',
    db.Column('task_id', db.Integer, db.ForeignKey('tasks.task_id'), primary_key=True),
    db.Column('user_id', db.Integer, db.ForeignKey('users.user_id'), primary_key=True)
)

# Define Task Model
class Task(db.Model):
    __tablename__ = 'tasks'
    task_id = db.Column(db.Integer, primary_key=True)
    task_name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    owner_id = db.Column(db.Integer, nullable=False)
    rank = db.Column(db.Integer, nullable=False)
    priority = db.Column(db.String(10), nullable=False)
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    due_date = db.Column(db.Date, nullable=False)
    status = db.Column(db.String(20), nullable=False)
    percent_complete = db.Column(db.Numeric(5, 2), nullable=False)
    estimated_days = db.Column(db.Integer)
    actual_days = db.Column(db.Integer)
    next_task_id = db.Column(db.Integer, db.ForeignKey('tasks.task_id'))
    project_id = db.Column(db.Integer, db.ForeignKey('projects.project_id'))
    is_locked = db.Column(db.Boolean, default=False)
    #Relationships
    assigned_users = db.relationship('User', secondary=task_assignments, backref='assigned_tasks')
    comments = db.relationship('Comment', back_populates='task', cascade='all, delete-orphan')

class User(db.Model):
    __tablename__ = 'users'  # Ensure this matches the SQL exactly, including case sensitivity
    user_id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    role_id = db.Column(db.Integer, db.ForeignKey('roles.role_id'))  # Reference should be roles.role_id
    role = db.relationship('Role', backref=db.backref('users', lazy=True))
    comments_posted = db.relationship('Comment', back_populates='commenter', lazy='dynamic')

class Role(db.Model):
    __tablename__ = 'roles'  # Ensure this matches the SQL exactly, including case sensitivity
    role_id = db.Column(db.Integer, primary_key=True)
    role_name = db.Column(db.String(50), nullable=False)
    description = db.Column(db.Text, nullable=True)


class Project(db.Model):
    __tablename__ = 'projects'
    
    # Matching columns in the database schema
    project_id = db.Column(db.Integer, primary_key=True, autoincrement=True)  # Matches `project_id INT PRIMARY KEY AUTO_INCREMENT`
    project_name = db.Column(db.String(100), nullable=False)  # Matches `project_name VARCHAR(100) NOT NULL`
    description = db.Column(db.Text)  # Matches `description TEXT`
    start_date = db.Column(db.Date)  # Matches `start_date DATE`
    end_date = db.Column(db.Date)  # Matches `end_date DATE`
    status = db.Column(db.String(20))  # Matches `status VARCHAR(20)`
    owner_id = db.Column(db.Integer, db.ForeignKey('users.user_id'))  # Matches `owner_id INT` with foreign key
    percent_complete = db.Column(db.Numeric(5, 2))  # Matches `percent_complete DECIMAL(5, 2)`
    created_by = db.Column(db.Integer, db.ForeignKey('users.user_id'))  # Matches `created_by INT` with foreign key
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())  # Matches `created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
    updated_at = db.Column(db.DateTime, default=db.func.current_timestamp(), onupdate=db.func.current_timestamp())  # Matches `updated_at TIMESTAMP`

    # Define relationships if needed (optional, depends on how you're accessing related data)
    owner = db.relationship('User', backref='owned_projects', foreign_keys=[owner_id])
    creator = db.relationship('User', foreign_keys=[created_by], backref='created_projects')
    comments = db.relationship('Comment', back_populates='project', cascade='all, delete-orphan', foreign_keys='[Comment.project_id]')
    # Add a relationship to `Task` model (assuming `Task` has a `project_id` foreign key)
    tasks = db.relationship('Task', backref='project', lazy='dynamic')
    @property
    def total_tasks(self):
        # This property will count related tasks dynamically
        return self.tasks.count() if self.tasks else 0

class Comment(db.Model):
    __tablename__ = 'comments'
    
    comment_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    comment_text = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())
    entity_type = db.Column(db.String(50), nullable=False)  # 'task' or 'project'
    entity_id = db.Column(db.Integer, nullable=False)       # ID of the associated task or project
    
    # Foreign Keys
    task_id = db.Column(db.Integer, db.ForeignKey('tasks.task_id'), nullable=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'))
    project_id = db.Column(db.Integer, db.ForeignKey('projects.project_id'), nullable=True)  # Nullable, used only if the comment is on a project
    
    # Relationships
    task = db.relationship('Task', back_populates='comments')
    commenter = db.relationship('User', back_populates='comments_posted')
    project = db.relationship('Project', back_populates='comments')

@app.route('/')
def index():
    return render_template('login.html')

@app.route('/sysadmin_dashboard')
def sysadmin_dashboard():
    return render_template('sysadmin_dashboard.html')

@app.route('/manager1_dashboard')
def manager1_dashboard():
    # Calculate task metrics
    total_tasks = Task.query.count()
    completed_tasks = Task.query.filter_by(status='Completed').count()
    in_progress_tasks = Task.query.filter_by(status='In Progress').count()
    not_started_tasks = Task.query.filter_by(status='Not Started').count()
    total_projects = Project.query.count()

    if total_tasks > 0:
        average_completion_percentage = Task.query.with_entities(db.func.avg(Task.percent_complete)).scalar() or 0
    else:
        average_completion_percentage = 0

    high_priority = Task.query.filter_by(priority='High').count()
    medium_priority = Task.query.filter_by(priority='Medium').count()
    low_priority = Task.query.filter_by(priority='Low').count()
    today = datetime.today().date()
    upcoming_deadlines = Task.query.filter(Task.due_date >= today).count()

    return render_template(
        'manager1_dashboard.html',
        total_tasks=total_tasks,
        completed_tasks=completed_tasks,
        in_progress_tasks=in_progress_tasks,
        not_started_tasks=not_started_tasks,
        upcoming_deadlines=upcoming_deadlines,
        total_projects=total_projects,
        average_completion_percentage=average_completion_percentage,
        high_priority=high_priority,
        medium_priority=medium_priority,
        low_priority=low_priority
    )

@app.route('/manager2_dashboard')
def manager2_dashboard():
    # Fetch all projects and tasks
    projects = Project.query.all()
    
    # Prepare team performance data (e.g., for bottom and top employees)
    project_data = []
    performance_data = []

    # Filter employees to only those assigned to Manager Level 1 users under this Manager Level 2
    employees = User.query.filter(User.role_id == 4).all()

    HIGH_PRIORITY_WEIGHT = 0.7
    NORMAL_PRIORITY_WEIGHT = 0.3

    for employee in employees:
        tasks = Task.query.filter_by(assigned_to=employee.user_id).all()

        # Initialize scores for the employee
        high_priority_score = 0
        normal_priority_score = 0
        high_priority_tasks = 0
        normal_priority_tasks = 0
        total_completed_tasks = 0
        total_tasks = 0
        total_completion_time = 0
        total_score = 0

        for task in tasks:
            # Determine task weight based on priority
            task_weight = HIGH_PRIORITY_WEIGHT if task.priority == 'High' else NORMAL_PRIORITY_WEIGHT
            
            #Data type conversions
            percent_complete = float(task.percent_complete) if isinstance(task.percent_complete, decimal.Decimal) else task.percent_complete

            # Calculate completion contribution based on `percent_complete`
            completion_score = (float(task.percent_complete) / 100) * task_weight

            # Timeliness adjustment - only penalize if the task is high priority and late
            if task.priority == 'High' and task.status != 'Completed' and task.due_date < date.today():# We might not want it to be today, we probably want actual days vs. due_date
                # Penalty based on how many days overdue the task is
                days_overdue = (date.today() - task.due_date).days
                estimated_days = float(task.estimated_days) if isinstance(task.estimated_days, decimal.Decimal) else task.estimated_days
                timeliness_penalty = min(days_overdue / estimated_days, 1) * task_weight
                completion_score -= timeliness_penalty

            # Adjust scores by priority
            if task.priority == 'High':
                high_priority_score += completion_score
                high_priority_tasks += 1
            else:
                normal_priority_score += completion_score
                normal_priority_tasks += 1
        print("User:", employee.user_id)
        print(f"Performance Data for {employee.username}: {round(total_score, 2)}")
        
        # Calculate average score per task type
        avg_high_priority_score = (high_priority_score / high_priority_tasks) if high_priority_tasks > 0 else 0
        avg_normal_priority_score = (normal_priority_score / normal_priority_tasks) if normal_priority_tasks > 0 else 0

        # Final performance score is a weighted average of high and normal priority scores
        total_score = (HIGH_PRIORITY_WEIGHT * avg_high_priority_score) + (NORMAL_PRIORITY_WEIGHT * avg_normal_priority_score)
        #Debug
        print("Total score:", total_score)

        # Store the calculated performance score for the employee
        performance_data.append({'username': employee.username, 'performance_score': round(total_score * 100, 2)})
    

    for project in projects:
        # Fetch the tasks related to the project
        tasks = Task.query.filter_by(project_id=project.project_id).all()
        completed_tasks = Task.query.filter_by(project_id=project.project_id, status='Completed').count()
        total_project_tasks = len(tasks)
        
        # Calculate progress percentage
        progress = (completed_tasks / total_project_tasks * 100) if total_project_tasks > 0 else 0
        
        # Calculate average completion time for each task
        total_project_completion_time = sum(task.actual_days for task in tasks if task.actual_days is not None)
        average_completion_time = (total_project_completion_time / completed_tasks) if completed_tasks > 0 else 0
        
        # Prepare data for the task completion rate
        task_completion_rate = (completed_tasks / total_project_tasks * 100) if total_project_tasks > 0 else 0
        
        # Calculate global totals for all projects
        total_completed_tasks += completed_tasks
        total_tasks += total_project_tasks
        total_completion_time += total_project_completion_time
        
        # Fetch owner details
        task = tasks[0] if tasks else None
        owner = User.query.filter_by(user_id=task.owner_id).first() if task else None
        team_member = owner.username if owner else 'N/A'
        
        # Append project-specific data
        project_data.append({
            'project_name': project.project_name,
            'status': task.status if task else 'N/A',
            'due_date': task.due_date.strftime('%Y-%m-%d') if task and task.due_date else 'N/A',
            'progress': round(progress, 2),
            'completed_tasks': completed_tasks,
            'total_tasks': total_project_tasks,
            'priority': task.priority if task else 'N/A',
            'team_members': team_member
        })
        
    # Fetch bottom and top performers for team performance
    performance_data.sort(key=lambda x: x['performance_score'])

   # Define minimum group sizes to ensure arrays are populated, even with small differences in scores
    num_employees = len(performance_data)
    bottom_count = max(2, min(3, num_employees - 1))  # At least 2 users in the bottom group
    top_count = max(2, min(3, num_employees - bottom_count))  # At least 2 users in the top group
    
    #Smaller sample Logic
    bottom_employees = performance_data[:bottom_count]
    top_performers = performance_data[-top_count:] if num_employees > bottom_count else []
    
    #Larger Sample logic
    #bottom_employees = performance_data[:max(1, int(0.1 * len(performance_data)))]
    #top_performers = performance_data[-int(0.05 * len(performance_data)):]
    
    global_completion_rate = (total_completed_tasks / total_tasks * 100) if total_tasks > 0 else 0
    global_average_completion_time = (total_completion_time / total_completed_tasks) if total_completed_tasks > 0 else 0
    
    #Debug
    print("Bottom Employees (Flask):", bottom_employees)
    print("Top Performers (Flask):", top_performers)

    # Edge Case Handling: If `top_performers` is empty, force at least one entry
    if not top_performers and len(performance_data) > 0:
        top_performers = [performance_data[-1]]  # Add the user with the highest score

    # Render the dashboard with all the data
    return render_template(
        'manager2_dashboard.html',
        projects=project_data,
        average_completion_time=round(global_average_completion_time, 2),
        task_completion_rate=round(global_completion_rate, 2),
        bottom_employees=bottom_employees,
        top_performers=top_performers
    )


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        user = User.query.filter_by(username=username).first()
        if user:
            if user.password == password:  # Replace with hashed password comparison for security
                session['user_id'] = user.user_id
                session['role'] = user.role_id

                # Debug: Print session data to verify
                print("Session Data:", "User ID:",session.get('user_id'),"Role_ID", session.get('role'))
                
                if 'sysadmin' in username.lower():
                    return redirect(url_for('sysadmin_dashboard'))
                elif 'manager1' in username.lower():
                    return redirect(url_for('manager_landing'))
                elif 'manager2' in username.lower():
                    return redirect(url_for('manager2_portal', user_id=user.user_id))
                else:
                    # Redirect to user landing page
                    return redirect(url_for('manager_projects', user_id=user.user_id))

            else:
                flash('Invalid username or password')
        else:
            flash('Invalid username or password')

    return render_template('login.html')



@app.route('/dashboard')
def dashboard():
    role = session.get('role')
    if role == 'user':
        return redirect(url_for('user_dashboard', user_id=session['user_id']))
    elif role == 'Manager1':
        return redirect(url_for('manager1_dashboard'))
    elif role == 'Manager2':
        return redirect(url_for('manager2_dashboard'))
    elif role == 'sysadmin':
        return redirect(url_for('sysadmin_dashboard'))
    else:
        return redirect(url_for('login'))

# Additional routes for new functionalities

# Route for managing users
@app.route('/manage_users')
def manage_users():
    users = User.query.all()  # Fetch all users from the database
    for user in users:
        print(f"User: {user.username}, Email: {user.email}")  # Debug print to ensure emails are being fetched
    return render_template('manage_users.html', users=users)

# Route for managing tasks
@app.route('/manage_tasks')
def manage_tasks():
    tasks = Task.query.all()
    return render_template('manage_tasks.html', tasks=tasks)

# Route for creating a new user
@app.route('/create_user', methods=['GET', 'POST'])
def create_user():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = generate_password_hash(request.form['password'])  # Secure password storage
        role_id = request.form['role_id']
        
        # Create and save the new user
        new_user = User(username=username, email=email, password=password, role_id=role_id)
        db.session.add(new_user)
        db.session.commit()
        flash('User created successfully!')
        return redirect(url_for('manage_users'))
    
    return render_template('create_user.html')  # Create this template with the form for adding a user

# Route for editing a user
@app.route('/edit_user/<int:user_id>', methods=['GET', 'POST'])
def edit_user(user_id):
    user = User.query.get_or_404(user_id)
    
    if request.method == 'POST':
        user.username = request.form['username']
        user.email = request.form['email']
        if request.form['password']:
            user.password = generate_password_hash(request.form['password'])  # Update the password only if provided
        user.role_id = request.form['role_id']
        
        db.session.commit()
        flash('User updated successfully!')
        return redirect(url_for('manage_users'))
    
    return render_template('edit_user.html', user=user)  # Create this template with a pre-filled form for editing a user

@app.route('/delete_user/<int:user_id>', methods=['POST'])
def delete_user(user_id):
    # Fetch the user from the database
    user = User.query.get_or_404(user_id)
    
    # Ensure all required fields are stored in the session before deletion
    session['deleted_user'] = {
        'user_id': user.user_id,
        'username': user.username,
        'email': user.email,  # Ensure email is correctly stored
        'password': user.password,
        'role_id': user.role_id
    }
    
@app.route('/delete_task/<int:task_id>', methods=['POST'])
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    flash('Task deleted successfully!')
    return redirect(url_for('manage_tasks'))
    # Perform the deletion
    db.session.delete(user)
    db.session.commit()
    
    # Flash message with undo option
    flash(f"User '{user.username}' deleted. <a href='{url_for('undo_delete_user')}'>Undo</a>", 'info')
    return redirect(url_for('manage_users'))


@app.route('/undo_delete_user', methods=['GET', 'POST'])
def undo_delete_user():
    # Check if a user was deleted and stored in the session
    deleted_user = session.pop('deleted_user', None)
    
    if deleted_user:
        # Recreate the user from the session data
        user = User(
            user_id=deleted_user['user_id'],
            username=deleted_user['username'],
            email=deleted_user['email'],
            password=deleted_user['password'],
            role_id=deleted_user['role_id']
        )
        db.session.add(user)
        db.session.commit()
        flash(f"User '{user.username}' restored successfully!", 'success')
    else:
        flash("No recent deletion to undo.", 'warning')
    
    return redirect(url_for('manage_users'))


# Route for viewing system reports
@app.route('/system_reports')
def system_reports():
    return render_template('system_reports.html')

# Route for settings page
@app.route('/settings')
def settings():
    return render_template('settings.html')

# Example route for creating tasks
# @app.route('/create_task', methods=['GET', 'POST'])
# def create_task():
#     if request.method == 'POST':
#         task_name = request.form['task_name']
#         description = request.form['description']
#         # Additional task fields processing
#         new_task = Task(task_name=task_name, description=description, owner_id=1, rank=1, priority='Medium', 
#                         start_date=date.today(), end_date=date.today(), due_date=date.today(), status='Not Started', 
#                         percent_complete=0.0)
#         db.session.add(new_task)
#         db.session.commit()
#         flash('Task created successfully!')
#         return redirect(url_for('manage_tasks'))
#     return render_template('create_task.html')

#Much better create tasks route, we need to make sure
#all of the variables are defined in each relevant class,
#and match up with our database variables.
@app.route('/create_task', methods=['GET', 'POST'])
def create_task():
    if request.method == 'POST':
        # Required fields
        task_name = request.form.get('task_name')
        description = request.form.get('description')

        # Ensure required fields are provided
        if not task_name or not description:
            flash("Task name and description are required.")
            return redirect(url_for('create_task'))

        # Optional fields with default values
        priority = request.form.get('priority', 'Medium')
        status = request.form.get('status', 'Not Started')
        start_date = request.form.get('start_date', date.today())
        end_date = request.form.get('end_date', date.today())
        due_date = request.form.get('due_date', date.today())
        percent_complete = request.form.get('percent_complete', 0.0)

        # Get user ID from session for the owner/creator of the task
        owner_id = session.get('user_id', 1)  # Default to 1 if user_id not in session

        # Retrieve assigned user and project from form
        assigned_user_ids = request.form.getlist('assigned_users')
        project_id = request.form.get('project_id')

        # Debug: Print task details including assignments
        print("Debug - Task Details:")
        print(f"  Task Name: {task_name}")
        print(f"  Description: {description}")
        print(f"  Priority: {priority}")
        print(f"  Status: {status}")
        print(f"  Start Date: {start_date}")
        print(f"  End Date: {end_date}")
        print(f"  Due Date: {due_date}")
        print(f"  Percent Complete: {percent_complete}")
        print(f"  Project ID: {project_id}")

        # Create the new task instance
        new_task = Task(
            task_name=task_name,
            description=description,
            owner_id=owner_id,
            rank=1,  # Consider adding logic to set rank dynamically
            priority=priority,
            start_date=start_date,
            end_date=end_date,
            due_date=due_date,
            status=status,
            percent_complete=percent_complete,
            project_id=project_id  # Assign to the selected project
        )

        assigned_users = User.query.filter(User.user_id.in_(assigned_user_ids)).all()
        new_task.assigned_users.extend(assigned_users)

        # Attempt to save the task
        try:
            db.session.add(new_task)
            db.session.commit()
            flash('Task created successfully!')
            print("Debug - Task successfully created and committed to the database.")
        except Exception as e:
            db.session.rollback()
            flash(f"An error occurred while creating the task: {e}")
            print("Debug - Error occurred while creating the task:", e)

        return redirect(url_for('manage_tasks'))

    # On GET request, retrieve users and projects for the dropdowns
    available_users = User.query.filter_by(role_id=4).all()  # Assuming role_id 4 corresponds to general users
    available_projects = Project.query.all()

    # Debug: Output available users and projects for dropdowns
    print("Debug - Available Users:", [(user.user_id, user.username) for user in available_users])
    print("Debug - Available Projects:", [(project.project_id, project.project_name) for project in available_projects])

    return render_template('create_task.html', users=available_users, projects=available_projects)

# Route for editing a task, need to flesh out.
@app.route('/edit_task/<int:task_id>', methods=['GET', 'POST'])
def edit_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    if request.method == 'POST':
        # Update task details based on form inputs
        task.task_name = request.form['task_name']
        task.description = request.form['description']
        task.status = request.form['status']
        task.priority = request.form['priority']
        task.start_date = datetime.strptime(request.form['start_date'], '%Y-%m-%d')
        task.end_date = datetime.strptime(request.form['end_date'], '%Y-%m-%d')
        task.due_date = datetime.strptime(request.form['due_date'], '%Y-%m-%d')
        task.percent_complete = float(request.form['percent_complete'])

        db.session.commit()
        flash('Task updated successfully!')
        return redirect(url_for('manage_tasks'))
    
    return render_template('edit_task.html', task=task)

@app.route('/manager_edit_task/<int:task_id>', methods=['GET', 'POST'])
def manager_edit_task(task_id):
    task = Task.query.get_or_404(task_id)
    project = Project.query.get(task.project_id)

    if request.method == 'POST':
        # Update task details based on form inputs
        task.task_name = request.form['task_name']
        task.description = request.form['description']
        task.status = request.form['status']
        task.priority = request.form['priority']
        task.start_date = datetime.strptime(request.form['start_date'], '%Y-%m-%d')
        task.end_date = datetime.strptime(request.form['end_date'], '%Y-%m-%d')
        task.due_date = datetime.strptime(request.form['due_date'], '%Y-%m-%d')
        task.percent_complete = float(request.form['percent_complete'])

        assigned_user_ids = request.form.getlist('assigned_users')
        task.assigned_users = User.query.filter(User.user_id.in_(assigned_user_ids)).all()

        db.session.commit()
        flash('Task updated successfully!')
        
        # Redirect back to the project_tasks route, passing the project_id
        return redirect(url_for('project_tasks', project_id=project.project_id))
    
    users = User.query.filter_by(role_id=4).all()
    return render_template('manager_edit_task.html', task=task, project=project, users=users)



@app.route('/Manager2landing')  # This is the route that triggers the HTML file rendering
def manager_dashboard():
    return render_template('Manager2landing.html')  # Make sure the filename is correct

@app.route('/managerlanding')  # The route to serve the manager landing page
def manager_landing():
    return render_template('managerlanding.html')  # Renders the managerlanding.html template

@app.route('/projectviewmanager1')  # Define the route for the project view page
def project_view_manager1():
    return render_template('projectviewmanager1.html')  # Render the corresponding HTML file

@app.route('/userlanding')  # Define the route for the user landing page
def user_landing():
    return render_template('userlanding.html')  # Render the user landing HTML page

@app.route('/user_project_view/<int:user_id>')
def user_project_view(user_id):
    user = User.query.get(user_id)
    tasks = Task.query.filter_by(assigned_to=user_id).all()

    if not user:
        flash('User not found!')
        return redirect(url_for('login'))

    return render_template('user_project_view.html', user=user, tasks=tasks)

#my shit   
###


#########################################################################


###
#other shit
@app.route('/logout')
def logout():
    # Clear the session to log out the user
    session.clear()
    return redirect(url_for('login'))  # Redirect the user to the login page

@app.route('/manager_projects', methods=['GET', 'POST'])
def manager_projects():
    # Check if user_id is in session
    user_id = session.get('user_id')
    role_id = session.get('role')
    print("Debug - user_id:", user_id)
    if not user_id or not role_id:
        flash("User not logged in. Please log in again.")
        return redirect(url_for('login'))

    # If it's a POST request, handle project creation
    if request.method == 'POST':
        # Get form data for new project
        project_name = request.form.get('project_name')
        start_date = request.form.get('start_date')
        end_date = request.form.get('end_date')
        owner_id = request.form.get('owner_id')  # Assuming this is the Level 1 manager ID

        # Create new project entry
        new_project = Project(
            project_name=project_name,
            start_date=start_date,
            end_date=end_date,
            status='Not Started',  # or other default status
            owner_id=owner_id,
            created_by=user_id,  # This is the Level 2 manager creating the project
            percent_complete=0.0  # Default value for new project
        )
        
        db.session.add(new_project)
        db.session.commit()
        flash('Project created successfully!')
        projectlist = Project.query.all()
        print("Debug project list:", projectlist)
        
        # Redirect to refresh the page and display the new project list
        return redirect(url_for('manager_projects'))

    # If it's a GET request, proceed to display projects
    print(f"Accessing projects for User ID: {user_id}, Role ID: {role_id}")

    # Fetch projects based on role
    if role_id == 2:  # Manager Level 1
        projects = Project.query.filter_by(owner_id=user_id).all()
        template = 'manager1_projectlist.html'
    elif role_id == 3:  # Manager Level 2
        projects = Project.query.filter_by(created_by=user_id).all()
        template = 'manager2_projectlist.html'
    elif role_id == 4:  # Employee
        # Fetch projects where the user is assigned as an employee (role_id == 4)
        projects = Project.query.join(Task, Project.project_id == Task.project_id).filter(Task.assigned_to == user_id).all()
        template = 'user_projectlist.html'
    else:
        flash("Access restricted. Invalid role.")
        return redirect(url_for('login'))

    # Convert projects to a list of dictionaries for rendering
    projects_data = []
    for project in projects:
        project_comments = Comment.query.filter(Comment.entity_type == 'project', Comment.entity_id == project.project_id).all()

        comments_data = [
            {
                'comment_id': comment.comment_id,
                'comment_text': comment.comment_text,
                'commenter': comment.commenter.username if comment.commenter else "Unknown",
                'created_at': comment.created_at.strftime('%Y-%m-%d %H:%M:%S')
            }
            for comment in project_comments
        ]
    
        projects_data.append({
            'project_id': project.project_id,
            'project_name': project.project_name,
            'description': project.description,
            'owner': project.owner.username if project.owner else "No owner",
            'percent_complete': float(project.percent_complete) if project.percent_complete else 0,
            'total_tasks': project.total_tasks,
            'start_date': project.start_date.strftime('%Y-%m-%d') if project.start_date else None,
            'end_date': project.end_date.strftime('%Y-%m-%d') if project.end_date else None,
            'status': project.status,
            'owner_id': project.owner_id,
            'comments': comments_data  # Include comments in the project data
        })
    # projects_data = [
    #     {
    #         'project_id': project.project_id,
    #         'project_name': project.project_name,
    #         'description': project.description,
    #         'owner': project.owner.username if project.owner else "No owner",
    #         'percent_complete': float(project.percent_complete) if project.percent_complete else 0,
    #         'total_tasks': project.total_tasks,
    #         'start_date': project.start_date.strftime('%Y-%m-%d') if project.start_date else None,
    #         'end_date': project.end_date.strftime('%Y-%m-%d') if project.end_date else None,
    #         'status': project.status,
    #         'owner_id': project.owner_id
    #     }
    #     for project in projects
    # ]

    # Retrieve Level 1 Managers for the "Assign to Level 1 Manager" dropdown
    level_1_managers = User.query.filter_by(role_id=2).all()

    # Render the template with projects_data and managers for dropdown
    return render_template(template, projects=projects_data, managers=level_1_managers, user_id=user_id)

@app.route('/project_tasks/<int:project_id>', methods=['GET', 'POST'])
def project_tasks(project_id):
    user_id = session.get('user_id')
    role_id = session.get('role')
    user = User.query.get(user_id)
    # Retrieve the current project
    project = Project.query.get_or_404(project_id)
    
    # Initialize empty lists for projects and users
    projects = []
    users = []

    # Only fetch projects and users for Level 1 Managers for dropdowns
    if role_id == 2:
        projects = Project.query.filter_by(owner_id=user_id).all()
        users = User.query.filter_by(role_id=4).all()  # Fetch all employees for assignment
    
    if request.method == 'POST':
        action = request.form.get('action')

        if action == 'create_task' and role_id == 2:
            # Handle task creation form submission
            task_name = request.form['task_name']
            description = request.form.get('description', '')
            status = request.form['status']
            priority = request.form['priority']
            start_date = request.form['start_date']
            end_date = request.form['end_date']
            due_date = request.form['due_date']
            percent_complete = request.form.get('percent_complete', 0)
            selected_project_id = request.form['project_id']  # Retrieve selected project from form
            assigned_user_ids = request.form.getlist('assigned_users')
            # Create and save the new task
            try:
                new_task = Task(
                    task_name=task_name,
                    description=description,
                    owner_id=user_id,
                    status=status,
                    priority=priority,
                    start_date=datetime.strptime(start_date, '%Y-%m-%d').date(),
                    end_date=datetime.strptime(end_date, '%Y-%m-%d').date(),
                    due_date=datetime.strptime(due_date, '%Y-%m-%d').date(),
                    percent_complete=percent_complete,
                    project_id=selected_project_id,  # Assign task to the selected project
                )
                # Add the multiple assigned users
                assigned_users = User.query.filter(User.user_id.in_(assigned_user_ids)).all()
                new_task.assigned_users.extend(assigned_users)

                db.session.add(new_task)
                db.session.commit()
                flash("Task created and assigned successfully!")
            except Exception as e:
                db.session.rollback()
                print("Error creating task:", e)
                flash("An error occurred while creating the task.")
            return redirect(url_for('project_tasks', project_id=project_id))
        
        elif action == 'edit_task':
            # Handle task editing
            task_id = request.form.get('task_id')
            task = Task.query.get_or_404(task_id)

            task.task_name = request.form.get('task_name')
            task.description = request.form.get('description', '')
            task.status = request.form.get('status', 'Not Started')
            task.priority = request.form.get('priority', 'Medium')
            task.start_date = datetime.strptime(request.form.get('start_date'), '%Y-%m-%d')
            task.end_date = datetime.strptime(request.form.get('end_date'), '%Y-%m-%d')
            task.due_date = datetime.strptime(request.form.get('due_date'), '%Y-%m-%d')
            task.percent_complete = float(request.form.get('percent_complete', 0))

            if 'assigned_users' in request.form:
                assigned_user_ids = request.form.getlist('assigned_users')
                task.assigned_users = User.query.filter(User.user_id.in_(assigned_user_ids)).all()

            db.session.commit()
            flash("Task updated successfully!")
            return redirect(url_for('project_tasks', project_id=project_id))
        
        elif action == 'delete_task':
            # Handle task deletion
            task_id = request.form.get('task_id')
            task = Task.query.get_or_404(task_id)
            
            db.session.delete(task)
            db.session.commit()
            flash("Task deleted successfully!")
            return redirect(url_for('project_tasks', project_id=project_id))
        
        elif action == 'add_comment':
            comment_text = request.form.get('comment_text')
            task_id = request.form.get('task_id')  # Identify which task to comment on
            entity_type = 'task'

            if comment_text and task_id:
                new_comment = Comment(
                    comment_text=comment_text,
                    entity_type=entity_type,
                    entity_id=task_id,
                    user_id=user_id
                )
                db.session.add(new_comment)
                db.session.commit()
                flash("Comment added successfully!")
            else:
                flash("Failed to add comment. Please ensure the comment text is filled in.")

            return redirect(url_for('project_tasks', project_id=project_id))

    # Fetch tasks based on the user's role
    tasks = []
    if role_id == 2:  # Level 1 Manager
        tasks = project.tasks.filter_by(owner_id=user_id).all()
    elif role_id == 3:  # Level 2 Manager
        tasks = project.tasks.all()
    elif role_id == 4:  # Employee
        tasks = project.tasks.filter(Task.assigned_users.any(User.user_id == user_id)).all()
    elif role_id == 1:
        tasks = project.tasks.all()
    else:
        flash("Access restricted. Invalid role.")
        return redirect(url_for('login'))

    # Convert tasks to dictionary format for template rendering
    tasks_data = [
        {
            'task_id': task.task_id,
            'task_name': task.task_name,
            'description': task.description,
            'status': task.status,
            'priority': task.priority,
            'assigned_users': [f"{user.first_name} {user.last_name}" for user in task.assigned_users],
            'start_date': task.start_date.strftime('%Y-%m-%d') if task.start_date else None,
            'due_date': task.due_date.strftime('%Y-%m-%d') if task.due_date else None,
            'end_date': task.end_date.strftime('%Y-%m-%d') if task.end_date else None,
            'percent_complete': str(task.percent_complete),
            'comments': [
                {
                    'comment_id': comment.comment_id,
                    'comment_text': comment.comment_text,
                    'commenter': comment.commenter.username if comment.commenter else "Unknown User",
                    'created_at': comment.created_at.strftime('%Y-%m-%d %H:%M:%S')
                }
                for comment in Comment.query.filter_by(entity_type='task', entity_id=task.task_id).all()
            ]
        }
        for task in tasks
    ]

    return render_template(
        'project_tasks.html', 
        user=user, 
        project=project, 
        tasks=tasks_data, 
        role_id=role_id, 
        projects=projects,  # Pass projects for the dropdown
        users=users  # Pass users for the dropdown
    )

@app.route('/toggle_task_lock/<int:task_id>', methods=['POST'])
def toggle_task_lock(task_id):
    user_id = session.get('user_id')
    role_id = session.get('role')
    
    # Ensure only SysAdmins can lock/unlock tasks
    if role_id != 1:  # Assuming SysAdmin role_id is 1
        flash("Access denied.")
        return redirect(url_for('sysadmin_dashboard'))
    
    task = Task.query.get_or_404(task_id)
    
    # Toggle the lock status
    task.is_locked = not task.is_locked
    db.session.commit()
    
    flash(f"Task '{task.task_name}' has been {'unlocked' if not task.is_locked else 'locked'} successfully!")
    return redirect(url_for('sysadmin_dashboard')) 

@app.route('/add_project_comment/<int:project_id>', methods=['POST'])
def add_project_comment(project_id):
    user_id = session.get('user_id')
    if not user_id:
        flash("You must be logged in to add comments.")
        return redirect(url_for('login'))

    comment_text = request.form.get('comment_text')
    if comment_text:
        try:
            # Create a new project-level comment
            new_comment = Comment(
                comment_text=comment_text,
                entity_type='project',  # Indicate this is a project comment
                entity_id=project_id,    # Use project_id as the entity_id
                user_id=user_id
            )
            db.session.add(new_comment)
            print(f"Comment created: {new_comment.comment_text}, Project ID: {project_id}, User ID: {user_id}")
            db.session.commit()
            flash("Project comment added successfully!")
        except Exception as e:
            db.session.rollback()
            print("Error adding project comment:", e)
            flash("An error occurred while adding the project comment.")
    else:
        flash("Comment text cannot be empty.")

    return redirect(url_for('manager_projects'))

@app.route('/manager1_projectlist')
def manager1_project_view():
    return render_template('manager1_projectlist.html') 

@app.route('/manager2_projectlist')
def manager2_project_view():
    return render_template('manager2_projectlist.html') 
 
@app.route('/manager2_portal/<int:user_id>')
def manager2_portal(user_id):
    user = User.query.get(user_id)
    if user is None:
        flash('User not found!')
        return redirect(url_for('login'))
    
    tasks = Task.query.filter(Task.assigned_users.any(User.user_id == user_id)).all()
    
    return render_template('manager2_portal.html', user_id=user_id, tasks=tasks)

@app.route('/manager2_dashboard') #Swapped this to the data analytics page -Jon
def manager2_data():
    tasks = Task.query.all()
    average_completion_time = 5  # Placeholder logic
    task_completion_rate = 80  # Placeholder logic
    active_projects = Project.query.count()
    upcoming_tasks = Task.query.filter(Task.due_date >= date.today()).all()
    bottom_employees = [{'name': 'John Doe', 'performance_score': 60}, {'name': 'Jane Smith', 'performance_score': 65}, {'name': 'Alice Johnson', 'performance_score': 70}]
    top_performers = [{'name': 'Michael Brown', 'performance_score': 95}, {'name': 'David Clark', 'performance_score': 90}, {'name': 'Sara White', 'performance_score': 85}]
 
    manager2_data.html
 
@app.route('/userlanding/<int:user_id>')
def userlanding(user_id):
    user = User.query.get(user_id)
    tasks = Task.query.filter_by(assigned_to=user_id).all()

    if user is None:
        flash('User not found!')
        return redirect(url_for('login'))

    return render_template('userlanding.html', user=user, tasks=tasks)

@app.route('/user_dashboard/<int:user_id>')
def user_dashboard(user_id):
    user = User.query.get(user_id)
    tasks = Task.query.filter_by(assigned_to=user_id).all()

    if not user:
        flash('User not found!')
        return redirect(url_for('login'))

    return render_template('manager_projects', user=user, tasks=tasks)

 
if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # Create tables if they don't exist
    app.run(debug=True)