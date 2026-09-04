namespace SuperpositionDemo {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;

    @EntryPoint()
    operation RunDemo() : Unit {
        Message("=== Démo 1 : Superposition ===");
        DemoSuperposition();

        Message("");
        Message("=== Démo 2 : Intrication (état de Bell) ===");
        DemoBellState();

        Message("");
        Message("=== Démo 3 : Téléportation quantique ===");
        for i in 1..5 {
            TeleportRandomState();
        }
    }

    /// # Résumé
    /// Met un qubit en superposition avec la porte H, le mesure plusieurs
    /// fois, et affiche la distribution des résultats.
    operation DemoSuperposition() : Unit {
        mutable zeros = 0;
        mutable ones = 0;
        let nbEssais = 1000;

        for i in 1..nbEssais {
            use q = Qubit();
            H(q); // Superposition : (|0> + |1>) / sqrt(2)
            let resultat = M(q);

            if resultat == Zero {
                set zeros += 1;
            } else {
                set ones += 1;
            }

            Reset(q); // Obligatoire avant de libérer le qubit
        }

        Message($"Sur {nbEssais} mesures : {zeros} fois |0>, {ones} fois |1>");
        Message("Chaque mesure individuelle donne un résultat net (0 ou 1).");
        Message("Seule la distribution statistique révèle la superposition initiale.");
    }

    /// # Résumé
    /// Crée deux qubits intriqués (état de Bell) et montre que leurs
    /// résultats de mesure sont toujours corrélés, même si chaque
    /// résultat pris isolément reste aléatoire.
    operation DemoBellState() : Unit {
        mutable memes = 0;
        mutable differents = 0;
        let nbEssais = 1000;

        for i in 1..nbEssais {
            use (q1, q2) = (Qubit(), Qubit());

            H(q1);       // q1 en superposition
            CNOT(q1, q2); // q2 devient intriqué avec q1

            let r1 = M(q1);
            let r2 = M(q2);

            if r1 == r2 {
                set memes += 1;
            } else {
                set differents += 1;
            }

            Reset(q1);
            Reset(q2);
        }

        Message($"Sur {nbEssais} mesures : {memes} fois résultats identiques, {differents} fois différents");
        Message("Les deux qubits sont corrélés à 100%, alors que chaque résultat individuel reste aléatoire.");
    }

    /// # Résumé
    /// Prépare un état "quelconque" (ni |0>, ni |1>) sur le qubit donné,
    /// pour que la téléportation qui suit soit vraiment convaincante :
    /// on ne téléporte pas juste un bit classique déguisé.
    operation PrepareState(q : Qubit) : Unit is Adj {
        Rx(1.234, q);
        Ry(0.567, q);
    }

    /// # Résumé
    /// Téléporte l'état préparé sur `msg` vers le qubit `there`, en
    /// utilisant uniquement une paire intriquée + deux bits classiques.
    /// Met en avant deux spécificités du langage Q# :
    ///  - le contrôle classique conditionné par un résultat de mesure (`if`)
    ///  - le functor `Adjoint`, qui génère automatiquement l'inverse d'une
    ///    opération (utilisé ici juste pour vérifier le résultat)
    operation TeleportRandomState() : Unit {
        use (msg, here, there) = (Qubit(), Qubit(), Qubit());

        // 1. Préparer l'état "secret" à téléporter
        PrepareState(msg);

        // 2. Créer la paire intriquée partagée (état de Bell) entre Alice et Bob
        H(here);
        CNOT(here, there);

        // 3. Alice intrique son message avec sa moitié de la paire
        CNOT(msg, here);
        H(msg);

        // 4. Alice mesure ses deux qubits : ce sont ces 2 bits classiques
        //    qu'elle enverrait réellement à Bob (par un canal classique)
        let m1 = M(msg);
        let m2 = M(here);

        // 5. Bob corrige son qubit selon les bits reçus
        if m2 == One { X(there); }
        if m1 == One { Z(there); }

        // 6. Vérification : Adjoint PrepareState "défait" la préparation.
        //    Si la téléportation a fonctionné, on doit retomber sur |0>.
        Adjoint PrepareState(there);
        let verif = M(there);

        if verif == Zero {
            Message("✅ État correctement téléporté");
        } else {
            Message("❌ Échec inattendu (ne devrait jamais arriver)");
        }

        ResetAll([msg, here, there]);
    }
}
