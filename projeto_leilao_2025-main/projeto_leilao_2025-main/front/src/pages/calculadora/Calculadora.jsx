import React, { useState } from "react";

const Calculadora = () => {

  const [valor1, setValor1] = useState("");
  const [valor2, setValor2] = useState("");
  const [operador, setOperador] = useState("");
  const [resultado, setResultado] = useState("");

  const calcular = () => {
    const v1 = parseFloat(valor1);
    const v2 = parseFloat(valor2);
    if (isNaN(v1) || isNaN(v2)) {
      return setResultado('valores Inválidos');
    }
    switch (operador) {
      case '+':
        setResultado(v1 + v2);
        break;
      case '-':
        setResultado(v1 - v2);
        break;
      case '*':
        setResultado(v1 * v2);
        break;
      case '/':
        setResultado(v2 !== 0 ? v1 / v2 : 'Divisão por 0');
        break;
      default:
        setResultado('Operador Inválido!');

    }
  }

  return (
    <>
      Valor 1:
      <input value={valor1} onChange={e => setValor1(e.target.value)} /><br />
      Valor 2:
      <input value={valor2} onChange={e => setValor2(e.target.value)} /><br />
      Operador:
      <input value={operador} onChange={e => setOperador(e.target.value)} /><br />
      <button onClick={() => calcular()}>Calcular</button><br /><br />
      {1 == 1 && resultado}
    </>
  );

}

export default Calculadora;