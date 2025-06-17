import React, { useState, useEffect } from 'react';

const Home = () => {
    const [tarefas, setTarefas] = useState([]);

    useEffect(() => {
        let tarefas = JSON.parse(localStorage.getItem("tarefas")) || [];
        setTarefas(tarefas);
    }, []);

    return (
        <>
            <h1>Página Inicial</h1>
            {tarefas.map(tarefa => (
                <p key={tarefa.id}>{tarefa.descricao}</p>
            ))}
        </>
    );
}
export default Home;
