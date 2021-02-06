AWS_PROFILE=rob VAULT_ADDR='http://127.0.0.1:8200' VAULT_TOKEN=$(cat .vault-token) packer build  ubuntu.pkr.hcl

aws --profile rob ec2 run-instances --image-id ami-03098c0107c176cdf --key-name rob --instance-type t2.nano --region us-east-1