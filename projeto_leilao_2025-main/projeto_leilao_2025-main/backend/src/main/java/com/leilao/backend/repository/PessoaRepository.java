package com.leilao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.leilao.backend.model.Pessoa;

public interface PessoaRepository extends JpaRepository<Pessoa, Long> {

}
