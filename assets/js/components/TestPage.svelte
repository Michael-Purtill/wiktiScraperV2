<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let langInfo = [];
    let selectors = [];

    onMount(async () => {
        let lang = window.location.pathname.split("/")[2];
        let word = encodeURIComponent(window.location.pathname.split("/")[3]);
        console.log(lang, word);

        fetch("/api/wordInfo/" + `${lang}/${word}`).then((r) => {return r.json()}).then((d) => {langInfo = d })
    });

    function handleClick(e) {
        if (_.includes(selectors, e.target.id)) {
            selectors = _.filter(selectors, s => s != e.target.id)
        }
        else {
            let selectorsCopy = _.cloneDeep(selectors);
            selectorsCopy.push(e.target.id);
            selectors = selectorsCopy;
        }
    }

    function handleSubmit() {
        fetch("/api/testPageJsonHandler", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({selectors: selectors, lang: "Czech", word: "pes"})
            
         }).then((res) => console.log(res));
    }

</script>

<div>
    {#each langInfo as datum, i}
        <div class="langInfoContainer">
            <h3>{datum.title.replaceAll("[ edit ]", "").replaceAll("[edit]", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</h3>
            {#each datum.content as content, j}
                {#if content.tag == "p"}
                <p id={`${i}:${j}`} on:click={handleClick}>{content.innerContent.replaceAll("\n", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</p>
                {:else if content.tag == "ul" || content.tag == "ol"}
                <ul id={`${i}:${j}`} on:click={handleClick}>
                    {#each content.innerContent as innerContent}
                        <li>{innerContent.replaceAll("\n", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</li>
                    {/each}
                </ul>
                {:else if content.tag="table"}
                <table>
                    <tbody>
                        {#each content.innerContent as innerContent, k}
                            <tr>
                                {#each innerContent as inner, l}
                                    <td id={`${i}:${j}->${k}:${l}`} on:click={handleClick}>{inner.replaceAll("\n", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</td>
                                {/each}
                            </tr>
                        {/each}
                    </tbody>
                </table>
                {/if}
            {/each}
        </div>
    {/each}
    <div class="langInfoContainer"><button on:click={handleSubmit}>Submit</button></div>
    
</div>

<style></style>