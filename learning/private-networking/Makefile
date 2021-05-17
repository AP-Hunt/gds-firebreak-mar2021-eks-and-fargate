apply:
	kubectl apply -f namespace.yml && \
	kubectl apply -f services.yml && \
	kubectl apply -f networkpolicy/

delete: delete-k8s-network-policy delete-calico
	kubectl delete -f networkpolicy/ && \
	kubectl delete -f services.yml && \
	kubectl delete -f namespace.yml &&
test:
	@echo "\n========\n"
	@echo "Test access from A to B"
	@echo "Expect this to succeed"
	@-kubectl exec \
	  -n private-networking \
	  "$$(kubectl get pods -n private-networking -l service=service-a -o json | jq -r '.items[] | .metadata.name')" \
	  -- wget -T10 -O - service-b.private-networking

	@echo "\n========\n"
	@echo "Test access from B to A"
	@echo "Expect this to succeed"
	@-kubectl exec \
	  -n private-networking \
	  "$$(kubectl get pods -n private-networking -l service=service-b -o json | jq -r '.items[] | .metadata.name')" \
	  -- wget -T10 -O - service-a.private-networking

	@echo "\n========\n"
	@echo "Test access from C to B"
	@echo "Expect this to fail"
	@-kubectl exec \
	  -n private-networking \
	  "$$(kubectl get pods -n private-networking -l service=service-c -o json | jq -r '.items[] | .metadata.name')" \
	  -- wget -T10 -O - service-b.private-networking
