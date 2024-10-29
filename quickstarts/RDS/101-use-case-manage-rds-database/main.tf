variable "region" {
  default = "cn-heyuan"
}

provider "alicloud" {
  region = var.region
}

variable "zone_id" {
  default = "cn-heyuan-b"
}

variable "instance_type" {
  default = "pg.n2.2c.2m"
}

# 创建VPC
resource "alicloud_vpc" "main" {
  vpc_name   = "alicloud"
  cidr_block = "172.16.0.0/16"
}

# 创建交换机
resource "alicloud_vswitch" "main" {
  vpc_id     = alicloud_vpc.main.id
  cidr_block = "172.16.192.0/20"
  zone_id    = var.zone_id
  depends_on = [alicloud_vpc.main]
}

# 创建RDS PostgreSQL实例
resource "alicloud_db_instance" "instance" {
  engine               = "PostgreSQL"
  engine_version       = "13.0"
  instance_type        = var.instance_type
  instance_storage     = "30"
  instance_charge_type = "Postpaid"
  vswitch_id           = alicloud_vswitch.main.id
  # 如果不需要创建VPC和交换机，使用已有的VPC和交换机
  # vswitch_id       = "vsw-****"
  # 创建多个配置相同的RDS PostgreSQL实例，x为需要创建的实例数量
  #count = x
}

resource "alicloud_db_database" "db" {
  instance_id = alicloud_db_instance.instance.id
  name        = "tf_database_test"
  # 修改或添加数据库备注
  description = "terraform_test"
}