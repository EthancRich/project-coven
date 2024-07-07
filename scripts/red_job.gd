class_name RedJob extends Job

# Functions
func _ready():
	self.employee_max = 4
	self.employee_num = 0
	self.progress = 0
	self.size = 1
	self.min_size = 1
	self.max_size = 3
	update_job_shape()

func _process(_delta):
	pass


		
