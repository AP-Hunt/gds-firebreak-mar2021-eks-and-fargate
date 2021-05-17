deploy: terraform-init terraform-apply post-apply

terraform-init:
	cd terraform/ && terraform init

terraform-apply:
	cd terraform/ && \
	terraform apply -state eks-andyhunt.tfstate -var deploy_env=andyhunt

terraform-destroy:
	cd terraform/ && \
	terraform destroy -state eks-andyhunt.tfstate -var deploy_env=andyhunt

kubectl:
	aws eks update-kubeconfig \
      --name "$$(terraform output -raw -state terraform/eks-andyhunt.tfstate cluster_name)" \
      --alias "$$(terraform output -raw -state terraform/eks-andyhunt.tfstate cluster_name)" && \
    kubectl config get-contexts "$$(kubectl config current-context)"

post-apply: kubectl patch-coredns patch-aws-node-role install-calico

patch-coredns:
	kubectl patch deployment coredns \
		--context "$$(terraform output -raw -state terraform/eks-andyhunt.tfstate cluster_name)" \
        -n kube-system \
        --type json \
        -p='[{"op": "replace", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type", "value": "fargate"}]' && \
	kubectl wait --for condition=available --timeout 5m deploy/coredns -n kube-system

patch-aws-node-role:
	# Annotate role and restart pods
	kubectl annotate serviceaccount \
      -n kube-system aws-node \
      --overwrite \
      "eks.amazonaws.com/role-arn=$$(terraform output -raw -state terraform/eks-andyhunt.tfstate aws_vpc_cni_role_arn)" && \
    kubectl delete pods -n kube-system -l k8s-app=aws-node

install-calico:
	# https://docs.aws.amazon.com/eks/latest/userguide/calico.html
	kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/master/calico-operator.yaml && \
    kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/master/calico-crs.yaml

deploy-2048:
	helm install apps-2048 kube-yaml/2048 \
		--set "replicaCount=2" \
		--set "ingress.certificateArn=$$(terraform output -raw -state terraform/eks-andyhunt.tfstate apps_domain_cert_arn)" \
		--set "namespace=apps"
