variable "region" {
  default = "cn-shenzhen"
}

variable "instance_name" {
  default = "alikafkaInstanceName"
}

variable "zone_id" {
  default = "cn-shenzhen-f"
}

provider "alicloud" {
  region = var.region
}

# 创建VPC
resource "alicloud_vpc" "default" {
  vpc_name   = "alicloud"
  cidr_block = "172.16.0.0/16"
}

# 创建交换机
resource "alicloud_vswitch" "default" {
  vpc_id     = alicloud_vpc.default.id
  cidr_block = "172.16.192.0/20"
  zone_id    = var.zone_id
}

# 创建安全组。
resource "alicloud_security_group" "default" {
  vpc_id = alicloud_vpc.default.id
}

# 创建实例，磁盘类型为高效云盘，磁盘容量为500 GB，流量规格为alikafka.hw.2xlarge。
# 部署实例。
resource "alicloud_alikafka_instance" "default" {
  name           = var.instance_name
  partition_num  = 50
  disk_type      = 0
  disk_size      = 500
  deploy_type    = 5
  io_max_spec    = "alikafka.hw.2xlarge"
  vswitch_id     = alicloud_vswitch.default.id
  security_group = alicloud_security_group.default.id
}

resource "alicloud_alikafka_instance_allowed_ip_attachment" "default" {
  instance_id  = alicloud_alikafka_instance.default.id
  allowed_type = "vpc"
  port_range   = "9092/9092"
  allowed_ip   = "192.168.0.0/32"
}
