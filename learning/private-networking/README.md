# Private networking

The aim of this little project is to deploy 3 services: a, b and c. Services A and C should be public-facing, and service B should share a private network with service A. It should reject traffic from anywhere else.

```nomnoml
#gravity: 2
#leading: 2
#spacing: 100
[A]
[B]
[C]
[Internet]

[A] allow <-> [B]
[C] disallow - [B]
[A] allow <-> [C]

[Internet] <-> can ingress/egress [A]
[Internet] <- can egress [B]
[Internet] <-> can ingress/egress [C]
```
