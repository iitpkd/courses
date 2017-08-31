---
title: Model Checking
code: CS4803
category: PME/PME*
credits: 3-1-0-4
prereq: []
consent: Yes
---

# Learning Objectives

In today’s world, many safety-critical systems are automatically controlled by an embedded code (automatic cars, aircrafts, pacemakers, etc).  As the size and the number of interacting components increase, the design and verification of these control software becomes increasingly complex and highly error-prone. Model checking is a field of research that addresses this challenge by making use of rigorous mathematical techniques. The key idea is to view control software as extensions of finite-state machines - this is the “model” of the software. Verification of the software translates to “checking” if the model satisfies certain properties. This is done by an algorithmic analysis of the model.

# Learning outcome

The goal of this course is to understand the theoretical foundations of model Checking technology and get a hands-on experience with a tool that performs model checking.

# Background

Familiarity with basic algorithms and finite-state machines

# Syllabus

*Module 1:* Modeling software and hardware as finite state machines (automata):
Models for simple control code and hardware circuits as transition systems; properties as formal languages; introduction to NuSMV model-checker

*Module 2:* Automata theory over finite and infinite words:
Review of DFAs, NFAs, closure properties; introduction to Büchi automata, non-deterministic and deterministic Büchi automata, closure properties.

*Module 3:* Temporal logics for specifying properties:
Linear Temporal Logic (LTL), converting LTL to Büchi automata, model-checking LTL on transition systems, Computation Tree Logics (CTL and CTL*), expressiveness of LTL, CTL and CTL*, model-checking CTL on transition systems

*Module 4:* Approaches for scaling model-checking to real systems:
Binary decision diagrams (BDDs), Satisfiability solving based model-checking algorithms

*Module 5:* Adding time to automata:
Modeling systems with timing constraints; introduction to timed automata

# References:

1. 	Principles of Model-checking,
	Christel Baier and Joost-Pieter Katoen,
	MIT Press (2008).
	ISBN-13: 978-0262026499

2. 	Decision Procedures,
	Daniel Kroening and Ofer Strichman,
	Springer (2ed, 2016)
	ISBN-13: 978-3662504963

# Meta Data

* Proposed in: 2017 July
* Proposing Faculty: Deepak Rajendraprasad for Dr. B. Srivathsan (CMI)
* Department / Centre: Computer Science and Engineering
* Programme: B.Tech
* Proposal Type: New course
* Offerings
	* 2017 Aug-Dec by Dr. B. Srivathsan (CMI)
