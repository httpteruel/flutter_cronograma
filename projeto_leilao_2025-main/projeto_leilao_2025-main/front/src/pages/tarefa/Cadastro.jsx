import React, { useState, useEffect } from "react";
import { Button } from 'primereact/button';

const Cadastro = () => {

    const [tarefa, setTarefa] = useState({ id: 0, descricao: '', data: '' });
    const [tarefas, setTarefas] = useState([]);

    useEffect(() => {
        let tarefas = JSON.parse(localStorage.getItem("tarefas")) || [];
        setTarefa({ ...tarefa, id: tarefas.length });
    }, []);

    const cadastrar = () => {
        tarefas.push(tarefa);
        localStorage.setItem("tarefas", JSON.stringify(tarefas));
    }

    const atualizarValor = (event) => {
        setTarefa({ ...tarefa, [event.target.id]: event.target.value });
        console.log(tarefa);
    }


    return (
        <>
            <h1>Cadastro de Tarefas</h1>
            {tarefa.descricao}
            <input type="text" value={tarefa.descricao} id="descricao" onChange={atualizarValor} /><br /><br />
            <input type="text" id="data" value={tarefa.data} onChange={atualizarValor} /><br /><br />
            <button onClick={cadastrar}>Cadastrar</button><br /><br />
            <Button label="Submit" />
        </>
    );
}
export default Cadastro;