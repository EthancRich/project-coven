class_name BlueJob extends Job

# Functions
func _ready():
	self.employee_max = 4
	self.employee_num = 0
	self.progress = 0
	self.size = 2
	self.min_size = 2
	self.max_size = 5
	update_job_shape()

func _process(_delta):
	pass


		
