package com.leilao.backend.service;

import org.springframework.stereotype.Service;

import com.leilao.backend.model.Calculadora;

@Service
public class HelloService {

    public Calculadora somar(Calculadora calculadora) {
        calculadora.setResultado(calculadora.getValor1() + calculadora.getValor2());
        return calculadora;
    }
}
